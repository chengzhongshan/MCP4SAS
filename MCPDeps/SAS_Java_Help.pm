package SAS_Java_Help;
use strict;
use warnings;

sub encryption_instructions {
    return <<'HELP';
SAS IOM encryption JAR setup:
  1. Open the official SAS download page and sign in with your SAS Profile:
     https://support.sas.com/downloads/package.htm?pid=2494
  2. Download and extract the SAS IOM client encryption package. Locate:
       sas.rutil.jar
       sas.rutil.nls.jar
       sastpj.rutil.jar
     Put all three files directly in one local directory, not inside the ZIP
     or a nested subdirectory. Keep this directory outside the Git checkout.
  3. From the MCP4SAS directory, configure the files you obtained from SAS:
       export MCP4SAS_SASPY_IOM_DIR="$HOME/sas-iom-encryption-jars"
     Replace the example directory with your actual extracted directory.
     For native Windows Python from Cygwin, use a Windows path, for example:
       export MCP4SAS_SASPY_IOM_DIR="$(cygpath -am "$HOME/sas-iom-encryption-jars")"
     Then configure and check the installation:
       bash install/install_saspy_iom_jars.sh
       bash install/check_mcp4sas_install.sh
  4. Apply the classpath to the Python/configuration used by the failing run.
     If SASPY_CFGFILE selects a custom config, update its IOM profile classpath
     too; rerunning the helper configures the installer's SASPy environment.
     Start a fresh session after changing the Java/classpath configuration.
  5. Check your selected target before resubmitting SAS code:
       perl run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
     Keep the same --saspy-cfgname/--saspy-cfgfile flags if you used them before.
MCP4SAS does not download these files, sign in to SAS, or bundle the archives.
SASPy documentation:
  https://sassoftware.github.io/saspy/configuration.html#sas-iom-client-encryption-jars
HELP
}

sub instructions {
    my ($text) = @_;
    $text //= '';
    return '' unless length $text;
    my $body;
    if ($text =~ /SSPIAuthException|SEC_E_NO_CREDENTIALS|security package failed while authenticating/i) {
        $body = "Windows IOM authentication failed. Check the local SAS account, SSPI DLL path\n"
          . "and localhost resolution using docs/WINDOWS_LOCAL_IOM_SSPI.md.\n"
          . "This authentication error alone does not establish that encryption JARs are missing.\n";
    } elsif ($text =~ /SSLHandshakeException|PKIX path building failed/i) {
        $body = "Java could not validate or negotiate the secure connection. Check the selected\n"
          . "Java truststore, certificate chain and any organizational proxy configuration.\n"
          . "Do not disable certificate validation. Preserve the full exception for your administrator.\n"
          . "Troubleshooting: https://sassoftware.github.io/saspy/troubleshooting.html\n";
    } elsif ($text =~ /java\.net\.(?:ConnectException|UnknownHostException|SocketTimeoutException)/) {
        $body = "Java reported a network/DNS/timeout failure. Check the configured SAS host/port,\n"
          . "server availability and firewall connectivity. This is not evidence of a missing JAR.\n"
          . "Troubleshooting: https://sassoftware.github.io/saspy/troubleshooting.html\n";
    } elsif ($text =~ /OutOfMemoryError/) {
        $body = "The Java process ran out of memory. Preserve the full error, reduce the workload,\n"
          . "and check the selected profile's Java heap/javaparms settings before retrying.\n"
          . "Downloading encryption JARs does not repair a memory-exhaustion failure.\n";
    } elsif ($text =~ /(?:sas\.rutil(?:\.nls)?|sastpj\.rutil)\.jar|(?:NoClassDefFoundError|ClassNotFoundException)[^\n]*(?:com[.\/]sas[.\/].*encryp|sas[.\/]rutil)|exception was thrown during the encryption key exchange/i) {
        $body = "This error can occur when SAS encryption JARs are missing or the IOM classpath\n"
          . "is incomplete. Verify the files and preserve the full exception if it continues.\n" . encryption_instructions();
    } elsif ($text =~ /(?:java[^\n]*(?:command not found|No such file|does not exist|not found))|(?:Cannot run program|FileNotFoundError)[^\n]*java|could not (?:create|start) the Java Virtual Machine|unable to (?:start|find)[^\n]*java/i) {
        $body = "Java could not be located or started. Install Java using your platform installer,\n"
          . "or set SASPY_JAVA (Unix) / SASPY_JAVA_WIN (Windows) to an existing Java executable.\n"
          . "If SASPY_CFGFILE selects a custom profile, check its 'java' and 'javaparms' values.\n"
          . "Rerun: perl run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only\n";
    } elsif ($text =~ /ClassNotFoundException|NoClassDefFoundError|UnsupportedClassVersionError|UnsatisfiedLinkError|Exception in thread[^\n]*java|java\.lang\.[A-Za-z]+(?:Exception|Error)/) {
        $body = "Java reported a classpath, version or native-library error. Preserve the complete\n"
          . "exception and check the Java executable and classpath of the selected SASPy profile.\n"
          . "Install SASPy through the platform installer to obtain its Java bridge/package assets.\n"
          . "For missing SAS encryption classes, follow docs/JAVA_SETUP_TROUBLESHOOTING.md.\n"
          . "Troubleshooting: https://sassoftware.github.io/saspy/troubleshooting.html\n";
    }
    return '' unless defined $body;
    return "\n[MCP4SAS Java setup help]\n$body";
}

sub decorate_result {
    my ($result) = @_;
    return $result unless ref($result) eq 'HASH' && length($result->{error} // '');
    return $result if index($result->{error}, '[MCP4SAS Java setup help]') >= 0;
    my $help = instructions($result->{error});
    return $result unless length $help;
    return { %{$result}, error => $result->{error} . $help, java_setup_help => $help };
}

1;
