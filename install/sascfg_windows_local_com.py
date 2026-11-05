"""Local Windows SAS via COM; run with native Windows Python and pywin32.

This is an explicit local alternative to Java IOM. No remote host, port,
username or password is configured. Existing winlocal Java profiles are kept.
"""

SAS_config_names = ['winlocal_com']
SAS_config_options = {'lock_down': False, 'verbose': True, 'prompt': False}
winlocal_com = {'provider': 'sas.iomprovider', 'encoding': 'windows-1252'}
