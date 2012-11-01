from .decorators import *
from .context_managers import *


@host_settings
@requires('deploy_path')
def verun(cmd):
    "Runs a command after the virtualenv is activated."
    parent, path = os.path.split(env.deploy_path)
    with virtualenv(parent):
        run(cmd)


