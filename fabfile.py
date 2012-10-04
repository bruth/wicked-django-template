from fabric.api import *

PROJECT_PATH = '/home/thedevel/sites/{{ project_name }}-env/{{ project_name }}'


def mm_on():
    with cd(PROJECT_PATH):
        run('touch MAINTENANCE_MODE')


def mm_off():
    with cd(PROJECT_PATH):
        run('rm -f MAINTENANCE_MODE')


def deploy(tag):
    mm_on()
    with cd(PROJECT_PATH):
        run('git fetch')
        run('git co {}'.format(tag))
    migrate()
    reload()
    mm_off()


def migrate():
    with cd(PROJECT_PATH):
        run('./bin/manage.py syncdb --migrate')


def reload():
    with cd(PROJECT_PATH):
        run('touch server/uwsgi/production.ini')
