from fabric.api import cd, env, run, task
from ..api import host_settings, requires, requires_external


@requires('supervisor_conf_dir')
def symlink():
    with cd(env.deploy_path):
        run('ln -sf $PWD/server/supervisor/{host}.ini '
            '{supervisor_conf_dir}/{{ project_name }}-{role}.ini'.format(**env))


@task
@host_settings
@requires_external('supervisorctl')
def sighup():
    "Re-link supervisor config and force an update to supervisor."
    symlink()
    run('supervisorctl update')



