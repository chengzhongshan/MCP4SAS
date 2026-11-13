#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use SAS_Java_Help;
use SAS_ODA_Runner;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
use IPC::Open3;
use Symbol qw(gensym);

my $failure='RuntimeError: An exception was thrown during the encryption key exchange';
my $help=SAS_Java_Help::instructions($failure);
like($help,qr{https://support\.sas\.com/downloads/package\.htm\?pid=2494},'official SAS download link is included');
like($help,qr/SAS Profile/,'SAS sign-in requirement is explained');
for my $jar (qw(sas.rutil.jar sas.rutil.nls.jar sastpj.rutil.jar)) {
    like($help,qr/\Q$jar\E/,"required file $jar is named");
}
like($help,qr/MCP4SAS_SASPY_IOM_DIR/,'external-directory configuration is explained');
like($help,qr/install_saspy_iom_jars\.sh/,'configuration command is included');
like($help,qr/--check-saspy-connection-only/,'connection validation command is included');
like($help,qr/SASPY_CFGFILE.*custom config/,'custom configuration users get classpath guidance');
like($help,qr/cygpath -am/,'Cygwin users get native Windows path guidance');
like(SAS_Java_Help::instructions('java.lang.NoClassDefFoundError: com/sas/services/security/encryption/Cipher'),qr/pid=2494/,'missing encryption class gets the download instructions');
my $sspi=SAS_Java_Help::instructions('SSPIAuthException: SEC_E_NO_CREDENTIALS');
like($sspi,qr/WINDOWS_LOCAL_IOM_SSPI/,'SSPI failure gets its own troubleshooting guide');
unlike($sspi,qr/pid=2494/,'SSPI failure does not recommend downloading encryption JARs');
like(SAS_Java_Help::instructions('FileNotFoundError: /missing/java'),qr/SASPY_JAVA/,'missing Java executable gets runtime guidance');
like(SAS_Java_Help::instructions('java.lang.ClassNotFoundException: pyiom.saspy2j'),qr/Java bridge/,'missing bridge gets SASPy package guidance');
is(SAS_Java_Help::instructions('No SAS process attached'),'', 'generic session loss does not imply a Java dependency problem');
is(SAS_Java_Help::instructions('ERROR: Procedure PRIN not found.'),'','SAS programming errors get no Java instructions');
for my $case (
    ['javax.net.ssl.SSLHandshakeException: PKIX path building failed', qr/truststore/],
    ['java.net.UnknownHostException: example.invalid', qr/network\/DNS/],
    ['java.lang.OutOfMemoryError: Java heap space', qr/ran out of memory/],
) {
    my $specific=SAS_Java_Help::instructions($case->[0]);
    like($specific,$case->[1],'Java failure gets cause-specific recovery guidance');
    unlike($specific,qr/pid=2494/,'non-classpath failure does not recommend an encryption download');
}
my $original={status=>'error',error=>$failure};
my $decorated=SAS_Java_Help::decorate_result($original);
is($decorated->{status},'error','failure status remains unchanged');
is($original->{error},$failure,'caller input is preserved');
is(SAS_Java_Help::decorate_result($decorated)->{error},$decorated->{error},'repeated decoration does not duplicate help');

# Exercise the actual CLI probe without SAS, Java, credentials or network access.
my $fixture=tempdir('java-help-XXXX',TMPDIR=>1,CLEANUP=>1);
open my $stub,'>',File::Spec->catfile($fixture,'saspy.py') or die $!;
print {$stub} <<'PY';
class SASsession:
    def __init__(self, **kwargs):
        import logging
        logging.getLogger('saspy.sasioiom').critical('Java Error: java.lang.NoClassDefFoundError: com/sas/services/security/encryption/Cipher')
        raise RuntimeError('No SAS process attached. SAS process has terminated unexpectedly.')
PY
close $stub;
local $ENV{PIPELINE_PYTHON_BIN}=$ENV{PIPELINE_PYTHON_BIN} || 'python3';
local $ENV{PYTHONPATH}=SAS_ODA_Runner::_normalize_local_path_for_python($fixture,$ENV{PIPELINE_PYTHON_BIN});
local $ENV{SASPY_CFGNAME}='linuxlocal';
local $ENV{SASPY_CFGFILE}='';
my ($input,$output);
my $error=gensym;
my $pid=open3($input,$output,$error,$^X,"$Bin/../run_sas_codes_or_files_in_ODA.pl",'--check-saspy-connection-only');
close $input;
my $stdout=do {local $/; <$output>} // '';
my $stderr=do {local $/; <$error>} // '';
waitpid($pid,0);
isnt($? >> 8,0,'actual CLI still fails when its connection fails');
like($stdout.$stderr,qr/pid=2494/,'actual CLI connection failure prints the download link');
like($stdout.$stderr,qr/sastpj\.rutil\.jar/,'actual CLI prints extraction/file instructions');
unlike($stdout.$stderr,qr/password may be wrong/,'Java setup error is not presented as a password diagnosis');
for my $case (
    ['SAS submission','--code','proc print data=sashelp.class(obs=1); run;'],
    ['file listing','--dir4listing','~'],
) {
    my ($label,@args)=@{$case};
    my $child_error=gensym;
    my $child=open3(my $child_in,my $child_out,$child_error,$^X,
        "$Bin/../run_sas_codes_or_files_in_ODA.pl",@args,
        '--output-prefix',File::Spec->catdir($fixture,$label =~ s/ /_/gr),
        '--run-timeout-seconds','20');
    close $child_in;
    my $captured=(do {local $/; <$child_out>} // '') . (do {local $/; <$child_error>} // '');
    waitpid($child,0);
    isnt($? >> 8,0,"actual $label keeps its failure exit status");
    like($captured,qr/pid=2494/,"actual $label also includes Java recovery instructions");
    unlike($captured,qr/FileNotFoundError.*output\.run\.status/,
        "actual $label status path does not mask the underlying Java failure");
    unlike($captured,qr/WORK\/quota or memory exhaustion is possible/,"known Java failure is not overwritten by a quota/session-loss guess");
}
done_testing();
