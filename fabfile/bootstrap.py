from fabric.api import env
from .config import HOST_ROLES


env.roledefs = HOST_ROLES

host_roles = {}
for role in HOST_ROLES:
    for host in HOST_ROLES[role]:
        host_roles[host] = role

