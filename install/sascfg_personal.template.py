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

import os


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
    "java": os.environ.get("SASPY_JAVA", os.environ.get("MCP4SAS_JAVA", "java")),
    "iomhost": env_list("SASPY_ODA_IOMHOST", _oda_region_hosts.get(_oda_region, _oda_region_hosts["us1"])),
    "iomport": env_int("SASPY_ODA_IOMPORT", 8591),
    "authkey": os.environ.get("SASPY_ODA_AUTHKEY", "oda"),
    "encoding": os.environ.get("SASPY_SAS_ENCODING", "utf-8"),
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
    "java": os.environ.get("SASPY_JAVA", os.environ.get("MCP4SAS_JAVA", "java")),
    "encoding": os.environ.get("SASPY_LOCAL_SAS_ENCODING", "windows-1252"),
}

winiomwin = winlocal

# Optional remote licensed IOM servers, separate from SAS ODA.
iomlinux = {
    "java": os.environ.get("SASPY_JAVA", os.environ.get("MCP4SAS_JAVA", "java")),
    "iomhost": env_list("SASPY_IOMHOST", ["linux.iom.host"]),
    "iomport": env_int("SASPY_IOMPORT", 8591),
    "authkey": os.environ.get("SASPY_IOM_AUTHKEY", "iom"),
    "encoding": os.environ.get("SASPY_SAS_ENCODING", "utf-8"),
}

iomwin = {
    "java": os.environ.get("SASPY_JAVA", os.environ.get("MCP4SAS_JAVA", "java")),
    "iomhost": env_list("SASPY_IOMHOST", ["windows.iom.host"]),
    "iomport": env_int("SASPY_IOMPORT", 8591),
    "authkey": os.environ.get("SASPY_IOM_AUTHKEY", "iom"),
    "encoding": os.environ.get("SASPY_SAS_ENCODING", "windows-1252"),
}
