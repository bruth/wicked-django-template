import os
import sys

PROJECT_SRC_NAME = 'src'

# absolute path to the myproject directory
PROJECT_PATH = os.path.realpath(os.path.dirname(__file__))
# absolute path to myproject/src
PROJECT_SRC_PATH = os.path.join(PROJECT_PATH, PROJECT_SRC_NAME)
# absolute path to the myproject/src/apps directory
PROJECT_APPS_PATH = os.path.join(PROJECT_SRC_PATH, 'apps')
# lop off myproject name, get the environment name
ENVIRON_PATH = os.path.realpath(os.path.join(PROJECT_PATH, '..'))

os.environ['DJANGO_SETTINGS_MODULE'] = '%s.conf.settings' % PROJECT_SRC_NAME
os.environ['PYTHON_EGG_CACHE'] = '/tmp'

# activate virtual environment
activate_this = os.path.join(ENVIRON_PATH, 'bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

# check that the project module can be imported.
try:
    __import__(PROJECT_SRC_NAME)
except ImportError:
    # couldn't import the project, place it on the python path and try again.
    sys.path.insert(0, PROJECT_PATH)

    try:
        __import__(PROJECT_SRC_NAME)
    except ImportError:
        sys.stderr.write("Error: Can't import the \"%s\" project module." %
                         PROJECT_SRC_NAME)

sys.path.insert(0, PROJECT_SRC_PATH)
sys.path.insert(0, PROJECT_APPS_PATH)

# finally.. define the WSGI handler as the entry point to the application
from django.core.handlers.wsgi import WSGIHandler
application = WSGIHandler()
