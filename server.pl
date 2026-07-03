#!/usr/bin/env perl
BEGIN {
    require File::Basename;
    require File::Spec;
    require Config;
    require Cwd;
    require lib;

    my $script_dir = Cwd::abs_path(File::Basename::dirname(__FILE__))
      || File::Basename::dirname(__FILE__);
    my $platform_tag = lc($^O || '');
    $platform_tag =~ s/[^a-z0-9]+/_/g;

    my @local_perl_bases = grep { defined && length && -d $_ } (
        File::Spec->catdir($script_dir, 'local', 'perl5', 'lib', 'perl5'),
        File::Spec->catdir($script_dir, 'local', "perl5-$platform_tag", 'lib', 'perl5'),
    );
    for my $base (@local_perl_bases) {
        lib->import($base);
        for my $arch (glob(File::Spec->catdir($base, '*'))) {
            next unless -d $arch;
            next unless File::Basename::basename($arch) =~ /(?:-thread-multi|linux|gnu|darwin|MSWin32|cygwin|^x86_64|^aarch64|^arm64|^i[3-6]86)/i
              || -d File::Spec->catdir($arch, 'auto');
            lib->import($arch);
        }
    }

    my $deps = File::Spec->catdir($script_dir, 'MCPDeps');
    lib->import($deps) if -d $deps;

    my @path_prefixes = grep { defined && length && -d $_ } (
        File::Spec->catdir($script_dir, '.venv-pipeline', 'bin'),
        File::Spec->catdir($script_dir, '.venv-pipeline', 'Scripts'),
        $script_dir,
        $deps,
    );
    $ENV{PATH} = join(':', @path_prefixes, ($ENV{PATH} // ''));
    $ENV{PERL5LIB} = join(':', @local_perl_bases, $deps, ($ENV{PERL5LIB} // ''));

    my $python_record = File::Spec->catfile($script_dir, '.venv-pipeline', '.python-bin');
    if (!$ENV{PIPELINE_PYTHON_BIN} && -f $python_record) {
        if (open(my $fh, '<', $python_record)) {
            my $python = <$fh>;
            close $fh;
            chomp $python if defined $python;
            $ENV{PIPELINE_PYTHON_BIN} = $python if defined($python) && length($python);
        }
    }
}

use strict;
use warnings;
use FindBin qw($Bin);
use File::Basename qw(basename dirname);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use Cwd qw(abs_path getcwd);
use JSON::PP qw(encode_json);
use Mojo::Util qw(md5_sum);
use POSIX qw(WNOHANG);
use Mojolicious::Lite -signatures;

$ENV{MOJO_LOG_LEVEL} //= 'error';

sub text_result {
    my ($text) = @_;
    return { content => [{ type => 'text', text => ($text // '') }] };
}

sub is_truthy {
    my ($value) = @_;
    return 0 unless defined $value;
    return $value =~ /^(?:1|true|yes|y|on)$/i ? 1 : 0;
}

sub is_falsey {
    my ($value) = @_;
    return 0 unless defined $value;
    return $value =~ /^(?:0|false|no|n|off)$/i ? 1 : 0;
}

sub as_list {
    my ($value) = @_;
    return () unless defined $value;
    return @$value if ref($value) eq 'ARRAY';
    return ($value);
}

sub runner_path {
    my @candidates = (
        File::Spec->catfile($Bin, 'run_sas_codes_or_files_in_ODA.pl'),
        File::Spec->catfile($Bin, 'run_sas_codes_or_script_in_ODA.pl'),
    );
    for my $path (@candidates) {
        return $path if -f $path;
    }
    die "Cannot find run_sas_codes_or_files_in_ODA.pl under $Bin\n";
}

sub pid_is_running {
    my ($pid) = @_;
    return 0 unless defined($pid) && $pid =~ /^\d+$/;
    return kill(0, $pid) ? 1 : 0;
}

sub read_text_file {
    my ($path) = @_;
    return '' unless defined($path) && length($path) && -f $path;
    open(my $fh, '<', $path) or return '';
    local $/;
    my $text = <$fh>;
    close $fh;
    return defined($text) ? $text : '';
}

sub write_text_file {
    my ($path, $text) = @_;
    open(my $fh, '>', $path) or die "Cannot write $path: $!\n";
    print {$fh} ($text // '');
    close $fh;
}

sub find_status_for_pid {
    my ($pid) = @_;
    for my $pid_file (glob(File::Spec->catfile('tmp*', 'output.html.info.pid'))) {
        next unless -f $pid_file;
        my $stored = read_text_file($pid_file);
        chomp $stored;
        next unless defined($stored) && $stored eq "$pid";

        my $out_file = $pid_file;
        $out_file =~ s/\.pid$/.txt/;
        return ($pid_file, $out_file);
    }
    return;
}

sub find_local_direct_sas_status_for_pid {
    my ($pid) = @_;
    for my $pid_file (glob(File::Spec->catfile('tmp*', 'output.local_sas_direct.pid'))) {
        next unless -f $pid_file;
        my $stored = read_text_file($pid_file);
        chomp $stored;
        next unless defined($stored) && $stored eq "$pid";

        my $out_file = $pid_file;
        $out_file =~ s/\.pid$/.txt/;
        return ($pid_file, $out_file);
    }
    return;
}

sub resolve_helper_script_path {
    my ($script_name) = @_;
    return '' unless defined($script_name) && length($script_name);
    return $script_name if $script_name =~ m{[\\/]} && -f $script_name;

    my @candidates = (
        File::Spec->catfile($Bin, $script_name),
        File::Spec->catfile($Bin, 'MCPDeps', $script_name),
    );
    for my $dir (File::Spec->path()) {
        push @candidates, File::Spec->catfile($dir, $script_name);
    }

    for my $path (@candidates) {
        return $path if defined($path) && length($path) && -f $path;
    }
    return '';
}

sub write_pid_file {
    my ($path, $pid) = @_;
    open(my $fh, '>', $path) or die "Cannot write $path: $!\n";
    print {$fh} $pid;
    close $fh;
}

sub reap_child_if_finished {
    my ($pid) = @_;
    return 0 unless defined($pid) && $pid =~ /^\d+$/;
    my $reaped = waitpid($pid, WNOHANG);
    return ($reaped && $reaped > 0) ? 1 : 0;
}

sub local_direct_sas_tool_schema {
    return {
        type => 'object',
        properties => {
            sas_codes_or_file => {
                type => 'string',
                description => 'Raw SAS code or a local .sas file path. This direct local SAS runner starts a fresh SAS process for each call.',
            },
            output_file => {
                type => 'string',
                description => 'Optional MCP wrapper output text file. Default: tmp*/output.local_sas_direct.txt.',
            },
            pid => {
                type => 'integer',
                description => 'PID from a previous direct local SAS call. Supply it to poll status.',
            },
            tmp_sas_file => {
                type => 'string',
                description => 'Optional internal temporary .sas file path used when raw SAS code is submitted.',
            },
            local_sas_exe => {
                type => 'string',
                description => 'Optional local SAS executable path. Passed as MCP4SAS_LOCAL_SAS_EXE to RunLocalSASDirectly.sh.',
            },
            local_sas_platform => {
                type => 'string',
                description => 'Optional platform override for RunLocalSASDirectly.sh: linux or windows.',
            },
        },
    };
}

sub mcp4sas_tool_schema {
    return {
        type => 'object',
        properties => {
            sas_codes_or_file => {
                type => 'string',
                description => 'Raw SAS code or a local .sas file path. Preserve newlines and semicolons exactly.',
            },
            output_file => {
                type => 'string',
                description => 'Optional output text file used by the MCP status wrapper. Default: tmp*/output.html.info.txt.',
            },
            upload_file => {
                oneOf => [
                    { type => 'string' },
                    { type => 'array', items => { type => 'string' } },
                ],
                description => 'Optional local file path, or list of paths, to upload to SAS ODA HOME.',
            },
            download_file => {
                oneOf => [
                    { type => 'string' },
                    { type => 'array', items => { type => 'string' } },
                ],
                description => 'Optional remote SAS ODA file path, or list of paths, to download.',
            },
            download_local_path => {
                oneOf => [
                    { type => 'string' },
                    { type => 'array', items => { type => 'string' } },
                ],
                description => 'Optional local destination path(s), paired positionally with download_file.',
            },
            delete_file => {
                oneOf => [
                    { type => 'string' },
                    { type => 'array', items => { type => 'string' } },
                ],
                description => 'Optional remote SAS ODA file path, or list of paths, to delete.',
            },
            delete_file_rgx => {
                oneOf => [
                    { type => 'string' },
                    { type => 'array', items => { type => 'string' } },
                ],
                description => 'Optional regex pattern(s) for deleting remote files after listing delete_dir.',
            },
            delete_dir => {
                type => 'string',
                description => 'Remote directory scanned by delete_file_rgx. Default: ~.',
            },
            file_info => {
                oneOf => [
                    { type => 'string' },
                    { type => 'array', items => { type => 'string' } },
                ],
                description => 'Optional remote SAS ODA file path(s) to inspect.',
            },
            dir4listing => {
                type => 'string',
                description => 'Optional remote SAS ODA directory to list, for example ~/Macros.',
            },
            persistent => {
                type => 'string',
                description => 'Truth-like value to reuse a persistent SAS ODA session. Default: true.',
            },
            session_id => {
                type => 'string',
                description => 'Persistent SAS ODA session id. Default: mysession.',
            },
            sas_oda_account => {
                type => 'string',
                description => 'Optional SAS ODA account/email for first-run credential bootstrap.',
            },
            sas_oda_password => {
                type => 'string',
                description => 'Optional SAS ODA password for first-run credential bootstrap.',
            },
            prompt_sas_oda_auth => {
                type => 'string',
                description => 'Truth-like value to force SAS ODA credential refresh.',
            },
            saspy_cfgname => {
                type => 'string',
                description => 'Optional SASPy config name, for example oda, linuxlocal, local, default, or winlocal.',
            },
            saspy_cfgfile => {
                type => 'string',
                description => 'Optional path to a SASPy sascfg_personal.py file.',
            },
            check_saspy_connection_only => {
                type => 'string',
                description => 'Truth-like value to validate the selected SASPy config with PROC SETINIT and exit.',
            },
            run_timeout_seconds => {
                type => 'integer',
                description => 'Optional wrapper timeout for a long SAS submit.',
            },
            no_run_timeout => {
                type => 'string',
                description => 'Truth-like value to disable the wrapper timeout.',
            },
            kill_saspy_sessions => {
                type => 'string',
                description => 'Truth-like value to stop local SAS ODA wrapper/session-server/Java bridge processes.',
            },
            pid => {
                type => 'integer',
                description => 'PID from a previous call. Supply it to poll status.',
            },
        },
    };
}

sub run_sas_oda_tool {
    my ($args) = @_;
    $args ||= {};

    if (defined $args->{pid}) {
        my ($pid_file, $out_file) = find_status_for_pid($args->{pid});
        return text_result("ERROR: PID $args->{pid} not found or already completed.")
          unless $pid_file;

        reap_child_if_finished($args->{pid});
        if (pid_is_running($args->{pid})) {
            return text_result(
                "STATUS: RUNNING (PID $args->{pid})\n"
              . "Output file: $out_file\n"
              . "Ask the AI agent to check status again in a moment."
            );
        }

        my $content = read_text_file($out_file);
        my $runner_stdout = File::Spec->catfile(dirname($out_file), 'runner.stdout.txt');
        $content = read_text_file($runner_stdout)
          if (!defined($content) || $content eq '') && -f $runner_stdout;
        unlink $pid_file if -f $pid_file;
        return text_result(
            "STATUS: COMPLETE (PID $args->{pid})\n\n"
          . "SAS log for debugging saved to: " . ((defined($content) && length($content) && -f $runner_stdout && !-f $out_file) ? $runner_stdout : $out_file) . "\n\n"
          . $content
        );
    }

    my $tmpdir = tempdir('tmpXXXXXX', DIR => getcwd(), CLEANUP => 0);
    make_path($tmpdir) unless -d $tmpdir;

    my $out_file = $args->{output_file} // File::Spec->catfile($tmpdir, 'output.html.info.txt');
    my $pid_file = File::Spec->catfile($tmpdir, 'output.html.info.pid');
    my $output_prefix = $out_file;
    $output_prefix =~ s/\.html\.info\.txt$//;
    $output_prefix = File::Spec->catfile($tmpdir, 'output') if $output_prefix eq $out_file;

    my @runner_args = ('--output-prefix', $output_prefix);

    if (is_truthy($args->{kill_saspy_sessions})) {
        push @runner_args, '--kill-saspy-sessions';
    }

    my $persistent = exists($args->{persistent}) ? !is_falsey($args->{persistent}) : 1;
    my $session_id = $args->{session_id} // 'mysession';
    if ($persistent) {
        push @runner_args, '--persistent', '--session-id', $session_id;
    }

    if (defined($args->{run_timeout_seconds}) && $args->{run_timeout_seconds} =~ /^\d+$/) {
        push @runner_args, '--run-timeout-seconds', int($args->{run_timeout_seconds});
    }
    push @runner_args, '--no-run-timeout' if is_truthy($args->{no_run_timeout});

    my $sas_input = $args->{sas_codes_or_file};
    if (defined($sas_input) && length($sas_input)) {
        if (-f $sas_input) {
            push @runner_args, '--file', $sas_input;
        } else {
            my $code_file = File::Spec->catfile($tmpdir, 'input.sas');
            open(my $fh, '>', $code_file) or die "Cannot write $code_file: $!\n";
            print {$fh} $sas_input;
            close $fh;
            push @runner_args, '--file', $code_file;
        }
    }

    push @runner_args, map { ('--upload-file', $_) } as_list($args->{upload_file});
    push @runner_args, map { ('--download-file', $_) } as_list($args->{download_file});
    push @runner_args, map { ('--download-local-path', $_) } as_list($args->{download_local_path});
    push @runner_args, map { ('--delete-file', $_) } as_list($args->{delete_file});
    push @runner_args, map { ('--delete-file-rgx', $_) } as_list($args->{delete_file_rgx});
    push @runner_args, ('--delete-dir', $args->{delete_dir}) if defined($args->{delete_dir}) && length($args->{delete_dir});
    push @runner_args, map { ('--file-info', $_) } as_list($args->{file_info});
    push @runner_args, ('--dir4listing', $args->{dir4listing}) if defined($args->{dir4listing}) && length($args->{dir4listing});
    push @runner_args, ('--saspy-cfgname', $args->{saspy_cfgname}) if defined($args->{saspy_cfgname}) && length($args->{saspy_cfgname});
    push @runner_args, ('--saspy-cfgfile', $args->{saspy_cfgfile}) if defined($args->{saspy_cfgfile}) && length($args->{saspy_cfgfile});
    push @runner_args, '--check-saspy-connection-only' if is_truthy($args->{check_saspy_connection_only});

    my $pid = fork();
    return text_result('ERROR: Could not fork SAS ODA worker.') unless defined $pid;

    if ($pid == 0) {
        $ENV{PIPELINE_SAS_ODA_ACCOUNT} = $args->{sas_oda_account}
          if defined($args->{sas_oda_account}) && length($args->{sas_oda_account});
        $ENV{PIPELINE_SAS_ODA_PASSWORD} = $args->{sas_oda_password}
          if defined($args->{sas_oda_password}) && length($args->{sas_oda_password});
        $ENV{PIPELINE_FORCE_SAS_ODA_AUTH_PROMPT} = 1
          if is_truthy($args->{prompt_sas_oda_auth});
        $ENV{OPEN_RESULT} //= 0;

        my $stdout_log = File::Spec->catfile($tmpdir, 'runner.stdout.txt');
        open(STDOUT, '>', $stdout_log) or die "Cannot redirect stdout to $stdout_log: $!\n";
        open(STDERR, '>&STDOUT') or die "Cannot redirect stderr: $!\n";

        my $runner = runner_path();
        exec { $^X } $^X, $runner, @runner_args;
        die "Could not exec $runner: $!\n";
    }

    write_pid_file($pid_file, $pid);
    return text_result(
        "QUERYING: SAS ODA worker started\n"
      . "PID: $pid\n"
      . "Output file: $out_file\n"
      . "Temporary directory: $tmpdir\n"
      . "Ask the AI agent to check status with: {\"pid\": $pid}\n"
      . "For long SAS jobs, check no more than every 30 seconds."
    );
}

sub run_local_direct_sas_tool {
    my ($args) = @_;
    $args ||= {};

    if (defined $args->{pid}) {
        my ($pid_file, $out_file) = find_local_direct_sas_status_for_pid($args->{pid});
        return text_result("ERROR: PID $args->{pid} not found or already completed.")
          unless $pid_file;

        reap_child_if_finished($args->{pid});
        if (pid_is_running($args->{pid})) {
            return text_result(
                "STATUS: RUNNING (PID $args->{pid})\n"
              . "Output file: $out_file\n"
              . "Ask the AI agent to check status again in a moment."
            );
        }

        my $content = read_text_file($out_file);
        unlink $pid_file if -f $pid_file;
        return text_result(
            "STATUS: COMPLETE (PID $args->{pid})\n\n"
          . "Local SAS direct-run log for debugging saved to: $out_file\n\n"
          . $content
        );
    }

    my $sas_input = $args->{sas_codes_or_file};
    return text_result('ERROR: sas_codes_or_file is required for direct local SAS runs.')
      unless defined($sas_input) && length($sas_input);

    my $runner = resolve_helper_script_path('RunLocalSASDirectly.sh');
    return text_result(
        "ERROR: Cannot find RunLocalSASDirectly.sh. Place it in the MCP4SAS repository, MCPDeps, or PATH, "
      . "and set MCP4SAS_LOCAL_SAS_EXE, MCP4SAS_LINUX_SAS_EXE, or MCP4SAS_WINDOWS_SAS_EXE to the local SAS executable if needed."
    ) unless length($runner);

    my $tmpdir = tempdir('tmpXXXXXX', DIR => getcwd(), CLEANUP => 0);
    make_path($tmpdir) unless -d $tmpdir;

    my $out_file = $args->{output_file} // File::Spec->catfile($tmpdir, 'output.local_sas_direct.txt');
    my $pid_file = File::Spec->catfile($tmpdir, 'output.local_sas_direct.pid');
    my $sas_file = $args->{tmp_sas_file} // File::Spec->catfile($tmpdir, 'input.sas');

    my $code = -f $sas_input ? read_text_file($sas_input) : $sas_input;
    $code = "ods html path='.';\n$code" unless $code =~ /^\s*ods\s+html\s+path\s*=/i;
    write_text_file($sas_file, $code);

    my $pid = fork();
    return text_result('ERROR: Could not fork direct local SAS worker.') unless defined $pid;

    if ($pid == 0) {
        $ENV{OPEN_RESULT} //= 0;
        $ENV{MCP4SAS_LOCAL_SAS_EXE} = $args->{local_sas_exe}
          if defined($args->{local_sas_exe}) && length($args->{local_sas_exe});
        $ENV{MCP4SAS_LOCAL_SAS_PLATFORM} = $args->{local_sas_platform}
          if defined($args->{local_sas_platform}) && length($args->{local_sas_platform});

        open(STDOUT, '>', $out_file) or die "Cannot redirect stdout to $out_file: $!\n";
        open(STDERR, '>&STDOUT') or die "Cannot redirect stderr: $!\n";

        exec { 'bash' } 'bash', $runner, $sas_file, 'output.html.info', $tmpdir;
        die "Could not exec $runner through bash: $!\n";
    }

    write_pid_file($pid_file, $pid);
    return text_result(
        "QUERYING: direct local SAS batch worker started\n"
      . "PID: $pid\n"
      . "Output file: $out_file\n"
      . "Temporary directory: $tmpdir\n"
      . "Ask the AI agent to check status with: {\"pid\": $pid}\n"
      . "This direct local SAS tool starts a fresh SAS batch process for each call; it does not keep WORK tables, macro variables, librefs, options, or loaded macros for later calls."
    );
}

my @TOOLS = (
    {
        name => 'run_sas_codes_or_files_in_ODA',
        description => 'Submit SAS code or .sas files through SASPy. Use saspy_cfgname=oda for SAS ODA, linuxlocal/local/default for local Linux SAS, or winlocal for local Windows SAS through SASPy IOM. Supports persistent SASPy session reuse, ODA file upload/download/delete/list operations, and background status polling for long jobs.',
        inputSchema => mcp4sas_tool_schema(),
        code => sub ($args) { run_sas_oda_tool($args) },
    },
    {
        name => 'run_sas_codes_or_script_in_ODA',
        description => 'Compatibility alias for run_sas_codes_or_files_in_ODA.',
        inputSchema => mcp4sas_tool_schema(),
        code => sub ($args) { run_sas_oda_tool($args) },
    },
    {
        name => 'run_local_sas_without_saspy',
        description => 'Run SAS code or a .sas file with a local Linux SAS executable or local Windows sas.exe through RunLocalSASDirectly.sh, without SASPy. This is a one-shot batch runner with background PID polling only: persistent session reuse is not supported, and WORK data sets, macro variables, librefs, options, and loaded macros do not carry across tool calls. Use the SASPy-backed tool with saspy_cfgname=linuxlocal or winlocal when persistent local SAS session reuse is required and SASPy is available.',
        inputSchema => local_direct_sas_tool_schema(),
        code => sub ($args) { run_local_direct_sas_tool($args) },
    },
    {
        name => 'run_sas_codes_or_script_on_local_Windows',
        description => 'Compatibility alias for run_local_sas_without_saspy. Despite the historical name, the underlying RunLocalSASDirectly.sh helper can run local Linux SAS or local Windows sas.exe directly without SASPy. It is one-shot batch only and cannot preserve persistent SAS session state.',
        inputSchema => local_direct_sas_tool_schema(),
        code => sub ($args) { run_local_direct_sas_tool($args) },
    },
);

my $SERVER_INSTRUCTIONS =
  "MCP4SAS runs SAS code through SASPy using SAS OnDemand for Academics or a local SAS config. "
  . "Use run_sas_codes_or_files_in_ODA for SAS code, .sas files, uploads, downloads, deletes, listings, and file metadata. "
  . "Use saspy_cfgname=oda for SAS ODA, saspy_cfgname=linuxlocal/local/default for local Linux SAS, or saspy_cfgname=winlocal for local Windows SAS. "
  . "Use run_local_sas_without_saspy only for direct one-shot local Linux/Windows SAS batch jobs without SASPy; it cannot keep a persistent SAS session. "
  . "Long jobs return a PID; poll with {\"pid\": PID} no more than about every 30 seconds. "
  . "Do not expose this local server to untrusted networks, and avoid placing SAS ODA passwords in prompts unless intentionally bootstrapping credentials.";

if (@ARGV == 0) {
    print STDERR "Usage: $0 daemon -m production -l http://127.0.0.1:8080\n";
    exit 0;
}

my %sessions;

any '/mcp' => sub ($c) {
    my $json = $c->req->json;
    return $c->render(json => { error => 'No JSON' }, status => 400) unless $json;

    my $method = $json->{method} // '';

    if ($method eq 'initialize') {
        my $sid = md5_sum(time() . rand() . $$);
        $sessions{$sid} = { created => time() };
        return $c->render(json => {
            jsonrpc => '2.0',
            id => $json->{id},
            result => {
                protocolVersion => '2024-11-05',
                capabilities => { tools => { listChanged => \1 } },
                serverInfo => { name => 'MCP4SAS', version => '0.1.0' },
                instructions => $SERVER_INSTRUCTIONS,
                sessionId => $sid,
            },
        });
    }

    if ($method eq 'notifications/initialized') {
        return $c->render(json => { jsonrpc => '2.0', result => {} });
    }

    if ($method eq 'tools/list') {
        return $c->render(json => {
            jsonrpc => '2.0',
            id => $json->{id},
            result => {
                tools => [
                    map {
                        {
                            name => $_->{name},
                            description => $_->{description},
                            inputSchema => $_->{inputSchema},
                        }
                    } @TOOLS
                ],
            },
        });
    }

    if ($method eq 'tools/call') {
        my $tool_name = $json->{params}{name} // '';
        my $tool_args = $json->{params}{arguments} || {};
        my ($tool) = grep { $_->{name} eq $tool_name } @TOOLS;

        return $c->render(json => {
            jsonrpc => '2.0',
            id => $json->{id},
            error => { code => -32601, message => "Unknown tool: $tool_name" },
        }) unless $tool;

        my $result = eval { $tool->{code}->($tool_args) };
        if ($@) {
            return $c->render(json => {
                jsonrpc => '2.0',
                id => $json->{id},
                error => { code => -32603, message => "Execution error: $@" },
            });
        }

        return $c->render(json => {
            jsonrpc => '2.0',
            id => $json->{id},
            result => $result,
        });
    }

    if (!defined $json->{id}) {
        return $c->render(json => { jsonrpc => '2.0', result => {} });
    }

    return $c->render(json => {
        jsonrpc => '2.0',
        id => $json->{id},
        error => { code => -32601, message => "Method not found: $method" },
    });
};

app->start;
