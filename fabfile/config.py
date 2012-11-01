# Map of hosts to their respective roles. This enables using
# `fab -R production deploy:abc123` which maps to one or more
# hosts
HOST_ROLES = {
    'production': ['example.com'],
    'development': ['dev.example.com'],
}


# Map of each host and their settings. The '_' key is special
# and acts as the default settings for all hosts. Each host
# only needs to override what doesn't already exist in the
# default settings.
HOST_SETTINGS = {
    '_': {},
    'example.com': {},
    'dev.example.com': {},
}
