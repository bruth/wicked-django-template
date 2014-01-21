from distribute_setup import use_setuptools
use_setuptools()
from setuptools import setup, find_packages

PACKAGE = '{{ project_name }}'
VERSION = __import__(PACKAGE).get_version()

kwargs = {
    'name': PACKAGE,
    'version': VERSION,

    'packages': find_packages(exclude=[
        'tests',
        '*.tests',
        'tests.*',
        '*.tests.*',
    ]),

    'install_requires': [],

    'test_suite': 'test_suite',
    'tests_require': [],

    'author': '',
    'author_email': '',
    'description': '',
    'license': '',
    'keywords': '',
    'url': '',
    'classifiers': [],
}

setup(**kwargs)
