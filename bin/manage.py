#!/usr/bin/env python
import os
import sys

# absolute path to this 'project' directory
PROJECT_PATH = os.path.join(os.path.dirname(__file__), '..')
# absolute path to the project/src directory
PROJECT_SRC_PATH = os.path.join(PROJECT_PATH, 'src')
# absolute path to the project/src/apps directory
PROJECT_APPS_PATH = os.path.join(PROJECT_SRC_PATH, 'apps')

try:
    # assume one level up is a virtual environment and attempt to activate it
    activate_this = os.path.join(PROJECT_PATH, '../bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
except IOError:
    pass

# check that the project module can be imported.
try:
    __import__('src.conf.settings')
except ImportError:
    # couldn't import the project, place it on the python path and try again.
    sys.path.insert(0, PROJECT_PATH)

    try:
        __import__('src.conf.settings')
    except ImportError:
        sys.stderr.write('Error: Cannot import the "src" project module.')

# include all the local project apps
sys.path.insert(0, PROJECT_APPS_PATH)

# setup the environment
os.environ['DJANGO_SETTINGS_MODULE'] = 'src.conf.settings'
os.environ['PYTHON_EGG_CACHE'] = '/tmp'

from django.core.management import execute_from_command_line
execute_from_command_line()
