"""SASPy configuration template for MCP4SAS.

Copy this file to one of the locations SASPy/MCP4SAS searches:

    ./sascfg_personal.py
    ~/.config/saspy/sascfg_personal.py
    ~/sascfg_personal.py

Then select a configuration with SASPY_CFGNAME:

    SASPY_CFGNAME=oda
    SASPY_CFGNAME=linuxlocal
    SASPY_CFGNAME=winlocal

The values below can be overridden with environment variables so the same file
can be reused across Linux, macOS, Cygwin, WSL, and Windows Python installs.
"""

import importlib.util
import os
import shutil
import subprocess
import sys


def env_int(name, default):
    try:
        return int(os.environ.get(name, default))
    except Exception:
        return int(default)


def env_list(name, default):
    value = os.environ.get(name)
    if not value:
        return list(default)
    return [part.strip() for part in value.replace(";", ",").split(",") if part.strip()]


def env_words(name):
    value = os.environ.get(name, "").strip()
    return value.split() if value else []


def _to_windows_path(path):
    if sys.platform != "cygwin":
        return path
    try:
        return subprocess.check_output(["cygpath", "-w", path], text=True).strip()
    except Exception:
        return path


def _default_java():
    candidates = []
    java_home = os.environ.get("JAVA_HOME")
    if java_home:
        candidates.extend([os.path.join(java_home, "bin", "java"), os.path.join(java_home, "bin", "java.exe")])
    candidates.extend([
        "/opt/homebrew/opt/openjdk/bin/java",
        "/usr/local/opt/openjdk/bin/java",
        "/usr/bin/java",
        "/usr/local/bin/java",
    ])
    for candidate in candidates:
        if os.path.isfile(candidate):
            return _to_windows_path(candidate)
    return shutil.which("java") or "java"


def _default_classpath():
    spec = importlib.util.find_spec("saspy")
    if spec is None or not spec.origin:
        return ""
    saspy_dir = os.path.dirname(spec.origin)
    relative_jars = [
        "java/saspyiom.jar",
        "java/iomclient/log4j-1.2-api-2.12.4.jar",
        "java/iomclient/log4j-api-2.12.4.jar",
        "java/iomclient/log4j-core-2.12.4.jar",
        "java/iomclient/sas.security.sspi.jar",
        "java/iomclient/sas.core.jar",
        "java/iomclient/sas.svc.connection.jar",
        "java/iomclient/sas.rutil.jar",
        "java/iomclient/sas.rutil.nls.jar",
        "java/iomclient/sastpj.rutil.jar",
        "java/thirdparty/glassfish-corba-internal-api.jar",
        "java/thirdparty/glassfish-corba-omgapi.jar",
        "java/thirdparty/glassfish-corba-orb.jar",
        "java/thirdparty/pfl-basic.jar",
        "java/thirdparty/pfl-tf.jar",
    ]
    jars = [os.path.join(saspy_dir, rel) for rel in relative_jars]
    jars = [_to_windows_path(path) for path in jars if os.path.isfile(path)]
    return (";" if sys.platform in ("cygwin", "win32") else os.pathsep).join(jars)


_DEFAULT_JAVA = _default_java()
_DEFAULT_CLASSPATH = _default_classpath()
_CONFIGURED_JAVA = os.environ.get(
    "SASPY_JAVA_WIN", os.environ.get("SASPY_JAVA", os.environ.get("MCP4SAS_JAVA", _DEFAULT_JAVA))
)


SAS_config_names = [
    "oda",
    "linuxlocal",
    "local",
    "default",
    "winlocal",
    "winiomwin",
    "iomlinux",
    "iomwin",
]

SAS_config_options = {
    "lock_down": False,
    "verbose": True,
    "prompt": True,
}

SAS_output_options = {
    "output": os.environ.get("SASPY_OUTPUT", "html5"),
    "style": os.environ.get("SASPY_ODS_STYLE", "HTMLBlue"),
    "asis": False,
}

_oda_region_hosts = {
    "us1": ["odaws01-usw2.oda.sas.com", "odaws02-usw2.oda.sas.com"],
    "us2": ["odaws01-usw2-2.oda.sas.com", "odaws02-usw2-2.oda.sas.com"],
    "eu1": ["odaws01-euw1.oda.sas.com", "odaws02-euw1.oda.sas.com"],
    "ap1": ["odaws01-apse1.oda.sas.com", "odaws02-apse1.oda.sas.com"],
    "ap2": ["odaws01-apse1-2.oda.sas.com", "odaws02-apse1-2.oda.sas.com"],
}
_oda_region = os.environ.get("SASPY_ODA_REGION", "us1").lower()

oda = {
    "java": _CONFIGURED_JAVA,
    "iomhost": env_list("SASPY_ODA_IOMHOST", _oda_region_hosts.get(_oda_region, _oda_region_hosts["us1"])),
    "iomport": env_int("SASPY_ODA_IOMPORT", 8591),
    "authkey": os.environ.get("SASPY_ODA_AUTHKEY", "oda"),
    "encoding": os.environ.get("SASPY_SAS_ENCODING", "utf-8"),
    "classpath": os.environ.get("SASPY_ODA_CLASSPATH", _DEFAULT_CLASSPATH),
}

linuxlocal = {
    "saspath": os.environ.get(
        "SASPY_LOCAL_SAS_PATH",
        os.environ.get(
            "MCP4SAS_LOCAL_SAS_PATH",
            "/opt/sasinside/SASHome/SASFoundation/9.4/bin/sas_u8",
        ),
    ),
    "options": env_words("SASPY_LOCAL_SAS_OPTIONS"),
    "encoding": os.environ.get("SASPY_LOCAL_SAS_ENCODING", "utf-8"),
}

# Friendly aliases for Linux local SAS.
local = linuxlocal
default = linuxlocal

# Local Windows SAS via SASPy IOM. Do not set iomhost for local Windows SAS.
winlocal = {
    "java": _CONFIGURED_JAVA,
    "encoding": os.environ.get("SASPY_LOCAL_SAS_ENCODING", "windows-1252"),
    "classpath": os.environ.get("SASPY_ODA_CLASSPATH", _DEFAULT_CLASSPATH),
}

winiomwin = winlocal

# Optional remote licensed IOM servers, separate from SAS ODA.
iomlinux = {
    "java": _CONFIGURED_JAVA,
    "iomhost": env_list("SASPY_IOMHOST", ["linux.iom.host"]),
    "iomport": env_int("SASPY_IOMPORT", 8591),
    "authkey": os.environ.get("SASPY_IOM_AUTHKEY", "iom"),
    "encoding": os.environ.get("SASPY_SAS_ENCODING", "utf-8"),
    "classpath": os.environ.get("SASPY_ODA_CLASSPATH", _DEFAULT_CLASSPATH),
}

iomwin = {
    "java": _CONFIGURED_JAVA,
    "iomhost": env_list("SASPY_IOMHOST", ["windows.iom.host"]),
    "iomport": env_int("SASPY_IOMPORT", 8591),
    "authkey": os.environ.get("SASPY_IOM_AUTHKEY", "iom"),
    "encoding": os.environ.get("SASPY_SAS_ENCODING", "windows-1252"),
    "classpath": os.environ.get("SASPY_ODA_CLASSPATH", _DEFAULT_CLASSPATH),
}
