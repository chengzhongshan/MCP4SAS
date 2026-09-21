# SASPy Java supplement

This directory contains SASPy Java assets used by the installer when the
currently installed `saspy` package ships an incomplete or incompatible ODA IOM
classpath.

The installer copies `java/` into the repo-local Python environment before
writing `saspy/sascfg_personal.py`. This fixes SAS OnDemand connection failures
such as:

```text
An exception was thrown during the encryption key exchange.
SAS process has terminated unexpectedly.
```

These files were copied from a known-working SASPy 5.103.0 installation:

```text
/usr/local/anaconda3/lib/python3.12/site-packages/saspy/java
```

The upstream SASPy package declares the Apache Software License. A copy of the
SASPy license metadata from that installation is included as
`SASPY_LICENSE.md`.
