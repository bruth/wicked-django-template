from fabric.api import task, run, cd, env
from ..api import host_settings, virtualenv, requires


@task
@host_settings
@requires('deploy_path')
def migrate():
    "Syncs and migrates the database using South."
    with virtualenv():
        from django.conf import settings
        if not settings.DATABASES:
            return

        args = []
        try:
            __import__('south')
            args.append('--migrate')
        except ImportError:
            pass
        with cd(env.deploy_path):
            run('python bin/manage.py syncdb {}'.format(' '.join(args)))
