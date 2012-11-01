from fabric.api import cd, env, run, task
from ..api import host_settings, requires, requires_external


@task
@host_settings
@requires_external('git')
@requires('deploy_path')
def merge(commit):
    "Fetches the latest code and merges up the specified commit."
    with cd(env.deploy_path):
        run('git fetch')
        run('git merge {}'.format(commit))


