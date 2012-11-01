import os
from contextlib import contextmanager
from fabric.api import prefix, env
from .decorators import  host_settings


@contextmanager
@host_settings
def virtualenv():
    "Sets the context within an active virtualenv."
    parent, project = os.path.split(env.deploy_path)
    activate = os.path.join(parent, 'bin', 'activate')
    with prefix('. {}'.format(activate)):
        yield
