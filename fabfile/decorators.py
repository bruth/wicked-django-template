from __future__ import print_function
from functools import wraps
from fabric.api import env, settings, abort, run
from fabric.colors import red
from .config import HOST_SETTINGS
from . import bootstrap


__all__ = ['host_settings', 'requires', 'requires_external']


def get_settings_decorator(hosts_settings):
    hosts = {}
    defaults = hosts_settings.get('_', {})

    for host in hosts_settings:
        if host == '_': continue
        tmp = {}
        tmp.update(defaults)
        tmp.update(hosts_settings[host])
        hosts[host] = tmp

    def decorator(func):
        "Sets the context of the host with it's settings."
        @wraps(func)
        def inner(*args, **kwargs):
            role = bootstrap.host_roles.get(env.host, env.host)
            with settings(role=role, **hosts.get(env.host, {})):
                return func(*args, **kwargs)
        return inner

    return decorator


def requires(*keys):
    def decorator(func):
        @wraps(func)
        def inner(*args, **kwargs):
            for key in keys:
                try:
                    getattr(env, key)
                except AttributeError:
                    abort(red('Missing setting "{}" for task "{}".'.format(key, func.__name__)))
            return func(*args, **kwargs)
        return inner
    return decorator


def requires_external(*keys):
    def decorator(func):
        @wraps(func)
        def inner(*args, **kwargs):
            for key in keys:
                if run('which {}'.format(key)).failed:
                    abort(red('External binary "{}" could not be found'.format(key)))
            return func(*args, **kwargs)
        return inner
    return decorator


# Default host_settings decorator
host_settings = get_settings_decorator(HOST_SETTINGS)
