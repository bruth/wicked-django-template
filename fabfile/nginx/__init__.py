from fabric.api import cd, run, task, env, abort
from fabric.colors import yellow, red
from fabric.contrib.console import confirm
from ..api import host_settings, requires, requires_external


@requires('deploy_path', 'nginx_conf_dir')
def symlink():
    "Symlinks the nginx config to the host's nginx conf directory."
    with cd(env.deploy_path):
        run('ln -sf $PWD/server/nginx/{host}.conf '
            '{nginx_conf_dir}/{{ project_name }}-{host}.conf'.format(**env))

@task
@host_settings
@requires_external('nginx', 'supervisorctl')
def sighup():
    "Reloads nginx if the config test succeeds."
    symlink()
    if run('nginx -t').succeeded:
        pid = run('supervisorctl pid nginx')
        run('kill -HUP {}'.format(pid))
    elif not confirm(yellow('nginx config test failed. continue?')):
        abort(red('nginx config test failed. Aborting'))
