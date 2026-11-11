# Fix Java and SASPy IOM setup errors

MCP4SAS installs SASPy and uses the Java assets supplied by that Python package.
It does not bundle SAS Java archives or sign in to SAS to download them.
Local Linux STDIO and Windows COM connections do not use Java; select the
configuration and Python interpreter for the connection you intend to use.

## Missing SAS encryption JARs or encryption key exchange failure

SASPy documents the encryption files required by SAS ODA. An encryption key
exchange error can indicate missing files or an incomplete IOM classpath;
preserve the complete exception if the problem continues after configuration.

1. Open the [official SAS encryption download](https://support.sas.com/downloads/package.htm?pid=2494).
2. Sign in with your SAS Profile and download the SAS IOM client encryption
   package. Follow the requirements shown on SAS's download page.
3. Extract the package. Find these three files and place them directly in a
   directory outside your Git checkout:

   ```text
   sas.rutil.jar
   sas.rutil.nls.jar
   sastpj.rutil.jar
   ```

   Point to the directory containing the files, not the ZIP or a parent folder.
4. From the MCP4SAS directory, configure that external directory:

   ```bash
   export MCP4SAS_SASPY_IOM_DIR="$HOME/sas-iom-encryption-jars"
   bash install/install_saspy_iom_jars.sh
   bash install/check_mcp4sas_install.sh
   ```

   Replace the example path with your actual directory. From Cygwin, if your
   selected Python is native Windows Python, export its Windows spelling before
   running the commands above:

   ```bash
   export MCP4SAS_SASPY_IOM_DIR="$(cygpath -am "$HOME/sas-iom-encryption-jars")"
   ```

5. Check the same SASPy target/configuration that failed:

   ```bash
   perl run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
   ```

   Keep your original `--saspy-cfgname` / `--saspy-cfgfile` options or their
   `SASPY_CFGNAME` / `SASPY_CFGFILE` environment settings. A connection check
   establishes a real session; it is separate from the installation smoke test.

The helper updates the installer's SASPy environment. If you select a separate
Python or custom configuration, its IOM classpath must include these files too.
The shipped configuration template reads `MCP4SAS_SASPY_IOM_DIR`; an older custom
profile with a hardcoded classpath needs to be updated. Start a fresh session
after changing Java or its classpath, and recreate any required WORK data.

## Java executable missing or unable to start

Use the platform installer to provision Java, or point `SASPY_JAVA` (Unix) /
`SASPY_JAVA_WIN` (Windows) at the Java executable you intend to use. For example:

```bash
export SASPY_JAVA=/path/to/java/bin/java
# Cygwin/native Windows example; replace it with an existing executable:
export SASPY_JAVA_WIN='C:/path/to/java/bin/java.exe'
```

Check the selected custom profile's `java` and `javaparms` values as well.
Downloading encryption files does not install a Java runtime.

## Missing Java bridge/classes or Java version mismatch

For `ClassNotFoundException`, `NoClassDefFoundError` or
`UnsupportedClassVersionError`, retain the complete missing class/version
message. Check that the selected Python has the intended SASPy installation,
that its Java bridge exists, and that the selected configuration uses a
compatible Java executable and classpath. Rerun the platform installer to repair
SASPy package assets. Use the SAS download steps above only when the missing
classes concern the separately supplied SAS encryption files.

## Windows IOM authentication / SSPI errors

`SSPIAuthException`, `SEC_E_NO_CREDENTIALS` or “The security package failed while
authenticating a user” require authentication/localhost/native-library checks.
They do not by themselves establish that encryption JARs are missing. See
[Windows local IOM/SSPI troubleshooting](WINDOWS_LOCAL_IOM_SSPI.md).

## Network, TLS and memory errors

Java network exceptions get host/port, DNS and firewall guidance. TLS handshake
or certificate-chain failures get truststore/proxy guidance; certificate checks
must remain enabled. Java out-of-memory errors get workload/heap guidance.
These failures do not by themselves establish that encryption JARs are missing.

Official references:

- [SASPy encryption JAR configuration](https://sassoftware.github.io/saspy/configuration.html#sas-iom-client-encryption-jars)
- [SASPy troubleshooting](https://sassoftware.github.io/saspy/troubleshooting.html)
