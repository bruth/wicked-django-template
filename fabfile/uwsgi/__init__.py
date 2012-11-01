from fabric.api import env, run, task
from ..api import host_settings, requires_external


@task
@host_settings
@requires_external('supervisorctl')
def sighup():
    "Gets the PID for the wsgi process and sends a HUP signal."
    pid = run('supervisorctl pid {{ project_name }}-{role}'.format(**env))
    run('kill -HUP {}'.format(pid))



