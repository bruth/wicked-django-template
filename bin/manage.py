#!/usr/bin/env python
import os
import sys

# Add the project to the path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

# setup the environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', '{{ project_name }}.conf.settings')
os.environ.setdefault('PYTHON_EGG_CACHE', '/tmp')

from django.core.management import execute_from_command_line
execute_from_command_line()
