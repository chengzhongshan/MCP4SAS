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

    my $deps = File::Spec->catdir($script_dir, 'DiffGWASDeps');
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
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use Cwd qw(abs_path getcwd);
use JSON::PP qw(encode_json);
use Mojo::Util qw(md5_sum);
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

sub write_pid_file {
    my ($path, $pid) = @_;
    open(my $fh, '>', $path) or die "Cannot write $path: $!\n";
    print {$fh} $pid;
    close $fh;
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
          . "SAS log for debugging saved to: $out_file\n\n"
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

my @TOOLS = (
    {
        name => 'run_sas_codes_or_files_in_ODA',
        description => 'Submit SAS code or .sas files to SAS OnDemand for Academics through SASPy, with persistent session reuse, file upload/download/delete/list operations, and background status polling for long jobs.',
        inputSchema => mcp4sas_tool_schema(),
        code => sub ($args) { run_sas_oda_tool($args) },
    },
    {
        name => 'run_sas_codes_or_script_in_ODA',
        description => 'Compatibility alias for run_sas_codes_or_files_in_ODA.',
        inputSchema => mcp4sas_tool_schema(),
        code => sub ($args) { run_sas_oda_tool($args) },
    },
);

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
