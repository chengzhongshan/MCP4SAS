"""Local Linux SAS via STDIO. Set SAS_EXECUTABLE to your SAS launcher path."""
import os

SAS_config_names = ['linuxlocal']
SAS_config_options = {'lock_down': False, 'verbose': True}
linuxlocal = {
    'saspath': os.environ.get('SASPY_LOCAL_SAS_PATH', os.environ.get('SAS_EXECUTABLE', '/usr/local/SASHome/SASFoundation/9.4/sas')),
    'options': ['-fullstimer'],
    'encoding': os.environ.get('SASPY_LOCAL_SAS_ENCODING', 'utf-8'),
}
