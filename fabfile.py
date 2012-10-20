from __future__ import print_function, with_statement
import os
import json
from functools import wraps
from fabric.api import *
from fabric.colors import red, yellow, white
from fabric.contrib.console import confirm
from fabric.contrib.files import exists


HOSTS_MESSAGE = """\
Before using this fabfile, you must create a .fabhosts in your project
directory. It is a JSON file with the following structure:

    {
        "_": {
            "user": "bruth",
            "host_string": "example.com",
            "path": "~/sites/project-env/project",
            "repo_url": "git@github.com/bruth/project.git",
            "nginx_conf_dir": "~/etc/nginx/conf.d",
            "supervisor_conf_dir": "~/etc/supervisor.d"
        },
        "production": {},
        "development": {
            "path": "~/sites/project-dev-env/project"
        },
        "staging": {
            "path": "~/sites/project-stage-env/project"
        }
    }

The "_" entry acts as the default/fallback for the other host
settings, so you only have to define the host-specific settings.
The below settings are required:

* `user` - username to SSH into the host
* `host_string` - hostname or IP address of the host server
* `path` - path to the deployed project *within* it's virtual environment
* `repo_url` - URL to project git repository
* `nginx_conf_dir` - path to host's nginx conf.d directory
* `supervisor_conf_dir` - path to host's supervisor

Note, additional settings can be defined and will be set on the `env`
object, but the above settings are required at a minimum.
"""

# A few setup steps and environment checks
curdir = os.path.dirname(os.path.abspath(__file__))
hosts_file = os.path.join(curdir, '.fabhosts')

# Check for the .fabhosts file
if not os.path.exists(hosts_file):
    abort(white(HOSTS_MESSAGE))

base_settings = {
    'user': '',
    'host_string': '',
    'path': '',
    'repo_url': '',
    'nginx_conf_dir': '',
    'supervisor_conf_dir': '',
}

required_settings = ['user', 'host_string', 'path', 'repo_url',
    'nginx_conf_dir', 'supervisor_conf_dir']


def get_hosts_settings():
    # Load all the host settings
    hosts = json.loads(open(hosts_file).read())

    # Pop the default settings
    default_settings = hosts.pop('_', {})

    # Pre-populated defaults
    for host in hosts:
        base = base_settings.copy()
        base.update(default_settings)
        base.update(hosts[host])
        hosts[host] = base

    if not env.hosts:
        abort(red('Error: At least one host must be specified'))

    # Validate all hosts have an entry in the .hosts file
    for target in env.hosts:
        if target not in hosts:
            abort(red('Error: No settings have been defined for the "{}" host'.format(target)))
        settings = hosts[target]
        for key in required_settings:
            if not settings[key]:
                abort(red('Error: The setting "{}" is not defined for "{}" host'.format(key, target)))
    return hosts


hosts = get_hosts_settings()

def host_context(func):
    "Sets the context of the setting to the current host"
    @wraps(func)
    def decorator(*args, **kwargs):
        with settings(**hosts[env.host]):
            return func(*args, **kwargs)
    return decorator


@host_context
def merge_commit(commit):
    "Fetches the latest code and merges up the specified commit."
    with cd(env.path):
        run('git fetch')
        run('git merge {}'.format(commit))


@host_context
def syncdb_migrate():
    "Syncs and migrates the database using South."
    verun('./bin/manage.py syncdb --migrate')


@host_context
def symlink_nginx():
    "Symlinks the nginx config to the host's nginx conf directory."
    with cd(env.path):
        run('ln -sf $PWD/server/nginx/{host}.conf '
            '{nginx_conf_dir}/{{ project_name }}-{host}.conf'.format(**env))


@host_context
def reload_nginx():
    "Reloads nginx if the config test succeeds."
    symlink_nginx()

    if run('nginx -t').succeeded:
        pid = run('supervisorctl pid nginx')
        run('kill -HUP {}'.format(pid))
    elif not confirm(yellow('nginx config test failed. continue?')):
        abort('nginx config test failed. Aborting')


@host_context
def reload_supervisor():
    "Re-link supervisor config and force an update to supervisor."
    with cd(env.path):
        run('ln -sf $PWD/server/supervisor/{host}.ini '
            '{supervisor_conf_dir}/{{ project_name }}-{host}.ini'.format(**env))

    run('supervisorctl update')
    run('supervisorctl reread')


@host_context
def reload_wsgi():
    "Gets the PID for the wsgi process and sends a HUP signal."
    pid = run('supervisorctl pid {{ project_name }}')
    run('kill -HUP {}'.format(pid))


@host_context
def deploy(commit, force=False):
    setup()
    upload_settings()
    mm_on()
    merge_commit(commit)
    install_deps(force)
    syncdb_migrate()
    make()
    reload_nginx()
    reload_supervisor()
    reload_wsgi()
    mm_off()


@host_context
def make():
    "Rebuilds all static files using the Makefile."
    with prefix('rvm use default'):
        verun('make')


@host_context
def setup():
    "Sets up the initial environment."
    parent, project = os.path.split(env.path)

    if not exists(parent):
        run('virtualenv {}'.format(parent))

    with cd(parent):
        if not exists(project):
            run('git clone {repo_url} {project}'.format(project=project, **env))


@host_context
def upload_settings():
    "Uploads the non-versioned local settings to the server."
    local_path = os.path.join(curdir, 'settings/{}.py'.format(env.host))
    if os.path.exists(local_path):
        remote_path = os.path.join(env.path, '{{ project_name }}/conf/local_settings.py')
        local('scp {local_path} {user}@{host_string}:{remote_path}'\
            .format(local_path=local_path, remote_path=remote_path, **env))
    elif not confirm(yellow('No local settings found for host "{}". Continue anyway?'.format(env.host))):
        abort('No local settings found for host "{}". Aborting.')


@host_context
def install_deps(force=False):
    "Install dependencies via pip."
    if force:
        verun('pip install -U -r requirements.txt')
    else:
        verun('pip install -r requirements.txt')


@host_context
def verun(cmd):
    "Runs a command after the virtualenv is activated."
    with cd(env.path):
        with prefix('source ../bin/activate'):
            run(cmd)


@host_context
def mm_on():
    "Turns on maintenance mode."
    with cd(env.path):
        run('touch MAINTENANCE_MODE')


@host_context
def mm_off():
    "Turns off maintenance mode."
    with cd(env.path):
        run('rm -f MAINTENANCE_MODE')
