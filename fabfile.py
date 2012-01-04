from fabric.api import *

def mm_on():
    with cd('/usr/local/srv/apps/app-env/app/'):
        run('touch MAINTENANCE_MODE')
        
def mm_off():
    with cd('/usr/local/srv/apps/app-env/app/'):
        run('rm -f MAINTENANCE_MODE')
