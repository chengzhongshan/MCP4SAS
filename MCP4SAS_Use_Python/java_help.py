"""Actionable Java/ODA guidance without treating every network error as a JAR error."""
import re
JARS = ('sas.rutil.jar','sas.rutil.nls.jar','sastpj.rutil.jar')

def encryption_instructions():
    return ('Download and extract the three SAS IOM encryption JARs from SAS:\n'
            'https://support.sas.com/downloads/package.htm?pid=2494\n'
            'Sign in with your SAS Profile, accept the applicable download terms, '
            'download the archive for your platform, and extract it locally. '
            'MCP4SAS does not redistribute these SAS files.\n'
            + '\n'.join('  '+name for name in JARS)
            + '\nIn VS Code run MCP4SAS: Configure SAS Encryption JARs, or run\n'
            'python MCP4SAS_Use_Python/install.py --jars-dir YOUR_EXTRACTED_FOLDER\n'
            'Use the same Python/configuration as the failing job and a fresh session.\n')

def instructions(text):
    if re.search(r'SSPIAuthException|SEC_E_NO_CREDENTIALS|security package failed while authenticating',text,re.I):
        body = 'Windows IOM authentication failed. Check the local SAS account and SSPI DLL path. This is not evidence of missing encryption JARs.'
    elif re.search(r'SSLHandshakeException|PKIX path building failed',text,re.I):
        body = 'Check Java truststore, certificate chain and organizational proxy. Do not disable certificate validation.'
    elif re.search(r'java\.net\.(?:ConnectException|UnknownHostException|SocketTimeoutException)',text):
        body = 'Check SAS host/DNS and outbound TCP 8591 for SAS ODA. Ask IT/IS if company-network access is blocked. This is not evidence of a missing JAR.'
    elif 'OutOfMemoryError' in text:
        body = 'Check Java heap/javaparms and workload size. Downloading JARs does not repair memory exhaustion.'
    elif re.search(r'(?:sas\.rutil(?:\.nls)?|sastpj\.rutil)\.jar|(?:NoClassDefFoundError|ClassNotFoundException)[^\n]*(?:com[./]sas[./].*encryp|sas[./]rutil)|exception was thrown during the encryption key exchange',text,re.I):
        body = encryption_instructions()
    elif re.search(r'java.*(?:not found|No such file)|Cannot run program.*java|Java Virtual Machine|FileNotFoundError[^\n]*[/\\]java(?:\.exe)?\b',text,re.I):
        body = 'Install Java or set SASPY_JAVA / SASPY_JAVA_WIN to its executable. Check the selected SASPy profile.'
    elif re.search(r'(?:ClassNotFoundException|NoClassDefFoundError)[^\n]*pyiom[./]saspy2j',text,re.I):
        body = 'The SASPy Java bridge is missing from the selected environment or its classpath. Repair that SASPy installation (python -m pip install --upgrade saspy), then check the same SASPy profile and start a fresh session.'
    elif re.search(r'ClassNotFoundException|NoClassDefFoundError|UnsupportedClassVersionError|UnsatisfiedLinkError',text):
        body = 'Check the Java executable, version and selected SASPy profile classpath; preserve the full exception.'
    elif re.search(r'authinfo|authkey|credentials.*(?:missing|not configured|not found)',text,re.I):
        body = ('The selected SASPy profile could not find usable account credentials. '
                'For SAS ODA, enter them privately with python run_sas_codes_or_files_in_ODA.py '
                '--prompt-sas-oda-auth --check-saspy-connection-only. '
                'Keep the same --saspy-cfgfile/--saspy-cfgname; do not put passwords in AI chat.')
    else:
        return ''
    return '\n[MCP4SAS Java setup help]\n'+body+'\n'
