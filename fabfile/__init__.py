from __future__ import print_function
import os
from fabric.api import run, prefix, cd, task, env, put, abort
from fabric.colors import yellow, red
from fabric.contrib.console import confirm
from fabric.contrib.files import exists
from .api import verun, host_settings, requires, requires_external
from . import django, nginx, supervisor, uwsgi, git


@task
@host_settings
def deploy(commit, force=False):
    setup()
    upload_settings()
    mm_on()
    git.merge(commit)
    install_deps(force)
    django.syncdb()
    make()
    nginx.sighup()
    supervisor.sighup()
    uwsgi.sighup()
    mm_off()


@task
@host_settings
@requires_external('make', 'node')
def make():
    "Rebuilds all static files using the Makefile."

    # Bash no-op
    _prefix = ':'

    # Manually check for sass since RVM may be installed
    if run('which rvm').succeeded:
        _prefix = 'rvm use default'

    with prefix(_prefix):
        if run('which sass').failed:
            abort(red('Sass could not be found'))
        verun('make')


@task
@host_settings
@requires('deploy_path', 'repo_url')
@requires_external('git')
def setup():
    "Sets up the initial environment."
    parent, project = os.path.split(env.deploy_path)

    if not exists(parent):
        run('virtualenv {}'.format(parent))

    with cd(parent):
        if not exists(project):
            run('git clone {repo_url} {project}'.format(project=project, **env))


@task
@host_settings
@requires('deploy_path')
def upload_settings():
    "Uploads the non-versioned local settings to the server."
    project = os.path.dirname(os.path.dirname(__file__))
    local_path = os.path.join(project, 'settings/{}.py'.format(env.role))
    if os.path.exists(local_path):
        remote_path = os.path.join(env.deploy_path, '{{ project_name }}/conf/local_settings.py')
        put(local_path, remote_path)
    elif not confirm(yellow('No local settings found for role "{}". Continue anyway?'.format(env.role))):
        abort(red('No local settings found for host "{}". Aborting.'.format(env.role)))


@task
@host_settings
def install_deps(force=False):
    "Install dependencies via pip."
    if force:
        verun('pip install -U -r requirements.txt')
    else:
        verun('pip install -r requirements.txt')


@task
@host_settings
@requires('deploy_path')
def mm_on():
    "Turns on maintenance mode."
    with cd(env.deploy_path):
        run('touch MAINTENANCE_MODE')


@task
@host_settings
@requires('deploy_path')
def mm_off():
    "Turns off maintenance mode."
    with cd(env.deploy_path):
        run('rm -f MAINTENANCE_MODE')
