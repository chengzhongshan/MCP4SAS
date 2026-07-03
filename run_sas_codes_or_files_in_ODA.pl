#!/usr/bin/perl
BEGIN {
    require File::Basename;
    require File::Spec;
    require Config;
    require Cwd;
    require lib;
    my $current_arch = lc($Config::Config{archname} || '');
    my $current_os = lc($^O || '');
    my $is_arch_dir = sub {
        my ($dir) = @_;
        return 0 unless -d $dir;
        my $name = File::Basename::basename($dir);
        my $looks_arch_specific = ($name =~ /(?:-thread-multi|linux|gnu|darwin|MSWin32|cygwin|^x86_64|^aarch64|^arm64|^i[3-6]86)/i)
            || -d File::Spec->catdir($dir, 'auto');
        return 0 unless $looks_arch_specific;
        return 1 if $current_arch && (lc($name) eq $current_arch || index($current_arch, lc($name)) >= 0 || index(lc($name), $current_arch) >= 0);
        return 1 if $current_os eq 'cygwin' && $name =~ /cygwin/i;
        return 1 if $current_os =~ /linux/  && $name =~ /(?:linux|gnu)/i;
        return 1 if $current_os =~ /darwin/ && $name =~ /darwin/i;
        return 1 if $current_os =~ /mswin32/ && $name =~ /MSWin32/i;
        return 0;
    };
    my $script_dir = Cwd::abs_path(File::Basename::dirname(__FILE__)) || File::Basename::dirname(__FILE__);
    my $platform_tag = lc($^O || '');
    $platform_tag =~ s/[^a-z0-9]+/_/g;
    my $has_repo_python_env = 0;
    for my $root ($script_dir, File::Spec->catdir($script_dir, File::Spec->updir())) {
        if (-d File::Spec->catdir($root, '.venv-pipeline')) {
            $has_repo_python_env = 1;
            last;
        }
    }
    my $disable_local_perl = defined($ENV{PIPELINE_DISABLE_LOCAL_PERL})
      && $ENV{PIPELINE_DISABLE_LOCAL_PERL} =~ /^(?:1|true|yes|y|on)$/i;
    my $force_local_perl = defined($ENV{PIPELINE_FORCE_LOCAL_PERL})
      && $ENV{PIPELINE_FORCE_LOCAL_PERL} =~ /^(?:1|true|yes|y|on)$/i;
    if (!$disable_local_perl && !$force_local_perl && $current_os eq 'cygwin' && !$has_repo_python_env) {
        $disable_local_perl = 1;
    }
    for my $root ($script_dir, File::Spec->catdir($script_dir, File::Spec->updir())) {
        last if $disable_local_perl;
        my @base_candidates;
        if (defined $ENV{PIPELINE_PERL_LOCAL_DIR} && length $ENV{PIPELINE_PERL_LOCAL_DIR}) {
            push @base_candidates, File::Spec->catdir($ENV{PIPELINE_PERL_LOCAL_DIR}, 'lib', 'perl5');
        }
        push @base_candidates, File::Spec->catdir($root, 'local', 'perl5', 'lib', 'perl5');
        push @base_candidates, File::Spec->catdir($root, 'local', "perl5-$platform_tag", 'lib', 'perl5');
        my %seen_base;
        for my $base (@base_candidates) {
            next unless -d $base;
            next if $seen_base{$base}++;
            #print STDERR "Importing local Perl library path: $base\n";
            lib->import($base);
            for my $arch (glob(File::Spec->catdir($base, '*'))) {
                next unless $is_arch_dir->($arch);
                #print STDERR "Importing architecture-specific Perl library path: $arch\n";
                lib->import($arch);
            }
        }
    }
}
use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin;
use lib "$Bin/DiffGWASDeps";
use Getopt::Long;
use SAS_ODA_Runner;
use JSON::PP qw(encode_json decode_json);
use Cwd qw(abs_path getcwd);
use File::Basename;
use File::Copy qw(move);
use File::Find qw(find);
use File::Spec;
use File::Path qw(make_path);
use File::Temp qw(tempfile);
use POSIX qw(:sys_wait_h);
use Data::Dumper qw(Dumper);
use overload ();
use Scalar::Util qw(blessed);

my ($code, $file, $macro_dir, $no_html, $output_prefix, $help, $persistent, $session_id,
    $dry_run, $dir4listing, $monitor_status_file, $monitor_interval_seconds,
    $kill_saspy_sessions);
my ($internal_runner_result_json, $internal_execution_file, $internal_execution_code_file,
    $internal_macro_dir, $internal_open_html, $internal_persistent, $internal_session_id);
my (@upload_files, @download_files, @download_local_paths, @delete_files, @delete_file_rgxs, @file_infos);
my ($sas_oda_account, $sas_oda_password, $force_sas_oda_auth_prompt,
    $skip_sas_oda_auth_bootstrap, $check_sas_oda_login_only);
my ($cli_sas_run_timeout_seconds, $cli_sas_run_timeout_grace_seconds, $disable_run_timeout);
our $python_bin;
my $skip_upload_if_same = 1;
my $delete_dir = '~';
my $created_output_dir = 0;
my $default_sas_run_timeout_seconds = exists $ENV{SAS_ODA_DEFAULT_RUN_TIMEOUT_SECONDS}
    ? $ENV{SAS_ODA_DEFAULT_RUN_TIMEOUT_SECONDS}
    : 3600;
my $sas_run_timeout_seconds = exists $ENV{SAS_ODA_RUN_TIMEOUT_SECONDS}
    ? $ENV{SAS_ODA_RUN_TIMEOUT_SECONDS}
    : $default_sas_run_timeout_seconds;
my $sas_run_timeout_grace_seconds = $ENV{SAS_ODA_RUN_TIMEOUT_GRACE_SECONDS} // 15;
$sas_run_timeout_seconds = int($sas_run_timeout_seconds || 0);
$sas_run_timeout_grace_seconds = int($sas_run_timeout_grace_seconds || 15);

sub resolve_python_bin {
    if ($ENV{PIPELINE_PYTHON_BIN} && -x $ENV{PIPELINE_PYTHON_BIN}) {
        return $ENV{PIPELINE_PYTHON_BIN};
    }
    my @cands;
    my $perl_bin_dir = eval { File::Basename::dirname($^X) } || '';
    for my $root ($Bin, File::Spec->catdir($Bin, File::Spec->updir())) {
        my $record = File::Spec->catfile($root, '.venv-pipeline', '.python-bin');
        if (-f $record) {
            if (open my $fh, '<', $record) {
                my $line = <$fh>;
                close $fh;
                if (defined $line) {
                    chomp $line;
                    push @cands, $line if length $line;
                }
            }
        }
        push @cands,
          File::Spec->catfile($root, '.venv-pipeline', 'bin', 'python'),
          File::Spec->catfile($root, '.venv-pipeline', 'bin', 'python3'),
          File::Spec->catfile($root, '.venv-pipeline', 'Scripts', 'python.exe'),
          File::Spec->catfile($root, '.venv-pipeline', 'Scripts', 'python');
    }
    if ($perl_bin_dir && -d $perl_bin_dir) {
        push @cands, sort glob(File::Spec->catfile($perl_bin_dir, 'python*.exe'));
        push @cands,
          File::Spec->catfile($perl_bin_dir, 'python3'),
          File::Spec->catfile($perl_bin_dir, 'python');
    }
    if (defined $ENV{USERPROFILE} && length $ENV{USERPROFILE}) {
        push @cands, File::Spec->catfile($ENV{USERPROFILE}, 'anaconda3', 'python.exe');
    }
    push @cands, 'python3', 'python.exe', 'python';
    for my $cand (@cands) {
        return $cand if -x $cand;
        next unless $cand =~ /^(?:python3?|py)$/;
        return $cand if system($cand, '-c', 'import sys') == 0;
    }
    die "Could not resolve a Python interpreter for SAS ODA helper execution\n";
}

sub resolve_pythonpath {
    return $ENV{PYTHONPATH} if defined $ENV{PYTHONPATH} && length $ENV{PYTHONPATH};
    my @cands;
    my @roots = ($Bin, File::Spec->catdir($Bin, File::Spec->updir()));
    eval {
        my $cwd = getcwd();
        push @roots, $cwd if defined $cwd && length $cwd;
        push @roots, File::Spec->catdir($cwd, File::Spec->updir()) if defined $cwd && length $cwd;
        1;
    };
    if (defined $ENV{PIPELINE_WORKDIR} && length $ENV{PIPELINE_WORKDIR}) {
        push @roots, $ENV{PIPELINE_WORKDIR};
        push @roots, File::Spec->catdir($ENV{PIPELINE_WORKDIR}, File::Spec->updir());
    }
    my %seen_root;
    for my $root (@roots) {
        next unless defined $root && length $root;
        next if $seen_root{$root}++;
        push @cands,
          File::Spec->catdir($root, '.venv-pipeline', 'Lib', 'site-packages'),
          File::Spec->catdir($root, '.venv-pipeline', 'lib', 'site-packages');
        my @pyver_dirs = glob(File::Spec->catdir($root, '.venv-pipeline', 'lib', 'python*', 'site-packages'));
        push @cands, @pyver_dirs if @pyver_dirs;
    }
    my %seen;
    for my $cand (@cands) {
        next unless defined $cand && length $cand;
        next if $seen{$cand}++;
        return $cand if -d $cand;
    }
    return '';
}

sub sh_quote {
    my ($text) = @_;
    $text //= '';
    $text =~ s/'/'"'"'/g;
    return "'$text'";
}

sub find_executable_in_path {
    my ($cmd) = @_;
    return '' unless defined $cmd && length $cmd;
    if ($cmd =~ m{[\\/]} || File::Spec->file_name_is_absolute($cmd)) {
        return (-f $cmd && -x $cmd) ? $cmd : '';
    }
    my @exts = ('');
    if (($^O eq 'MSWin32' || $^O eq 'cygwin') && $cmd !~ /\.[A-Za-z0-9]+$/) {
        @exts = grep { length $_ } split /;/, ($ENV{PATHEXT} || '.EXE;.BAT;.CMD;.COM');
        push @exts, '';
    }
    for my $dir (File::Spec->path()) {
        next unless defined $dir && length $dir;
        for my $ext (@exts) {
            my $cand = File::Spec->catfile($dir, $cmd . $ext);
            return $cand if -f $cand && -x $cand;
        }
    }
    return '';
}

sub local_file_uri {
    my ($path) = @_;
    my $abs = abs_path($path) || File::Spec->rel2abs($path);
    $abs =~ s{\\}{/}g;
    $abs =~ s/([^A-Za-z0-9\-\._~\/:])/sprintf("%%%02X", ord($1))/eg;
    return "file://$abs";
}

sub detect_desktop_open_env {
    my %open_env;
    if (defined($ENV{OPEN_RESULT_DISPLAY}) && length($ENV{OPEN_RESULT_DISPLAY})) {
        $open_env{DISPLAY} = $ENV{OPEN_RESULT_DISPLAY};
        $open_env{XAUTHORITY} = $ENV{OPEN_RESULT_XAUTHORITY}
          if defined($ENV{OPEN_RESULT_XAUTHORITY}) && length($ENV{OPEN_RESULT_XAUTHORITY});
        return \%open_env;
    }

    return \%open_env unless $^O eq 'linux' && -d '/proc';
    my $current_display = $ENV{DISPLAY} // '';
    my @desktop_patterns = qr/\blxsession\b/, qr/\bopenbox\b/, qr/\bxfce4-session\b/,
      qr/\bgnome-session\b/, qr/\bplasmashell\b/;

    opendir(my $proc_dh, '/proc') or return \%open_env;
    my @pids = grep { /^\d+$/ } readdir($proc_dh);
    closedir($proc_dh);

    for my $pid (@pids) {
        my $cmdline_path = "/proc/$pid/cmdline";
        next unless -r $cmdline_path;
        open my $cmd_fh, '<', $cmdline_path or next;
        local $/;
        my $cmdline = <$cmd_fh> // '';
        close $cmd_fh;
        $cmdline =~ tr/\0/ /;
        next unless grep { $cmdline =~ $_ } @desktop_patterns;

        my $env_path = "/proc/$pid/environ";
        next unless -r $env_path;
        open my $env_fh, '<', $env_path or next;
        my $env_blob = <$env_fh> // '';
        close $env_fh;
        my %proc_env = map {
            my ($k, $v) = split /=/, $_, 2;
            defined($k) && defined($v) ? ($k => $v) : ()
        } split /\0/, $env_blob;
        my $desktop_display = $proc_env{DISPLAY} // '';
        next unless length $desktop_display;
        next if length($current_display) && $desktop_display eq $current_display;
        $open_env{DISPLAY} = $desktop_display;
        $open_env{XAUTHORITY} = $proc_env{XAUTHORITY}
          if defined($proc_env{XAUTHORITY}) && length($proc_env{XAUTHORITY});
        last;
    }
    return \%open_env;
}

sub launch_command_detached {
    my ($cmd, $open_env) = @_;
    return 0 unless ref($cmd) eq 'ARRAY' && @{$cmd};
    my $pid = fork();
    return 0 unless defined $pid;
    return 1 if $pid;

    eval { POSIX::setsid(); };
    if (ref($open_env) eq 'HASH') {
        for my $key (qw(DISPLAY XAUTHORITY)) {
            next unless defined($open_env->{$key}) && length($open_env->{$key});
            $ENV{$key} = $open_env->{$key};
        }
    }
    open STDIN,  '<', File::Spec->devnull();
    open STDOUT, '>', File::Spec->devnull();
    open STDERR, '>', File::Spec->devnull();
    exec { $cmd->[0] } @{$cmd};
    exit 127;
}

sub auto_open_local_file {
    my ($path) = @_;
    return 0 unless defined $path && length $path && -f $path;

    my @commands;
    my $open_env = detect_desktop_open_env();
    if ($^O eq 'cygwin' || $^O eq 'MSWin32') {
        push @commands, ['cygstart', $path] if find_executable_in_path('cygstart');
    } elsif ($^O eq 'darwin') {
        push @commands, ['open', $path] if find_executable_in_path('open');
    } else {
        my $uri = local_file_uri($path);
        my @browser_candidates;
        push @browser_candidates, $ENV{OPEN_RESULT_BROWSER}
          if defined($ENV{OPEN_RESULT_BROWSER}) && length($ENV{OPEN_RESULT_BROWSER});
        push @browser_candidates, qw(
          google-chrome-stable
          google-chrome
          chromium
          chromium-browser
          firefox
          brave-browser
          opera
        );
        my %seen_browser;
        for my $browser (@browser_candidates) {
            next if $seen_browser{$browser}++;
            my $browser_path = find_executable_in_path($browser);
            next unless $browser_path;
            push @commands, [$browser_path, $uri];
        }
        push @commands, ['xdg-open', $path] if find_executable_in_path('xdg-open');
        push @commands, ['open', $path] if find_executable_in_path('open');
    }

    if ($python_bin) {
        push @commands, [
            $python_bin,
            '-c',
            'import pathlib, sys, webbrowser; webbrowser.open(pathlib.Path(sys.argv[1]).resolve().as_uri())',
            $path,
        ];
    }

    for my $cmd (@commands) {
        if (launch_command_detached($cmd, $open_env)) {
            my $display_note = (ref($open_env) eq 'HASH' && $open_env->{DISPLAY})
              ? " on DISPLAY=$open_env->{DISPLAY}"
              : '';
            print "Requested browser open$display_note: $path\n";
            return 1;
        }
    }

    warn "WARNING: Could not auto-open $path with the system default browser. Set OPEN_RESULT=0 to suppress this attempt.\n";
    return 0;
}

sub status_timestamp {
    my @lt = localtime();
    return sprintf(
        '%04d-%02d-%02d %02d:%02d:%02d',
        $lt[5] + 1900, $lt[4] + 1, $lt[3], $lt[2], $lt[1], $lt[0]
    );
}

$python_bin = resolve_python_bin();

GetOptions(
    'code|codes|c=s' => \$code,
    'file|f=s' => \$file,
    'macro-dir|m=s' => \$macro_dir,
    'no-html-info' => \$no_html,
    'output-prefix|p=s' => \$output_prefix,
    'persistent!' => \$persistent,
    'session-id|s=s' => \$session_id,
    'upload-file|u=s@' => \@upload_files,
    'skip-upload-if-same!' => \$skip_upload_if_same,
    'download-file|d=s@' => \@download_files,
    'download-local-path=s@' => \@download_local_paths,
    'delete-file|k=s@' => \@delete_files,
    'delete-file-rgx=s@' => \@delete_file_rgxs,
    'delete-dir=s' => \$delete_dir,
    'dir4listing|l=s' => \$dir4listing,
    'file-info=s@' => \@file_infos,
    'sas-oda-account=s' => \$sas_oda_account,
    'sas-oda-password=s' => \$sas_oda_password,
    'prompt-sas-oda-auth!' => \$force_sas_oda_auth_prompt,
    'skip-sas-oda-auth-bootstrap!' => \$skip_sas_oda_auth_bootstrap,
    'check-sas-oda-login-only!' => \$check_sas_oda_login_only,
    'monitor-status-file=s' => \$monitor_status_file,
    'monitor-interval-seconds=i' => \$monitor_interval_seconds,
    'kill-saspy-sessions|kill-sas-oda-sessions|kill-saspy-session-server!' => \$kill_saspy_sessions,
    'run-timeout-seconds=i' => \$cli_sas_run_timeout_seconds,
    'run-timeout-grace-seconds=i' => \$cli_sas_run_timeout_grace_seconds,
    'no-run-timeout!' => \$disable_run_timeout,
    'dry-run' => \$dry_run,
    'help|h' => \$help,
    '_internal-runner-result-json=s' => \$internal_runner_result_json,
    '_internal-execution-file=s' => \$internal_execution_file,
    '_internal-execution-code-file=s' => \$internal_execution_code_file,
    '_internal-macro-dir=s' => \$internal_macro_dir,
    '_internal-open-html=i' => \$internal_open_html,
    '_internal-persistent!' => \$internal_persistent,
    '_internal-session-id=s' => \$internal_session_id,
) or die "Error in command line arguments\n";

sub collect_sas_oda_session_pids {
    my %seen;
    my @pids;
    return @pids if $^O =~ /^(?:MSWin32|cygwin)$/i;

    open(my $ps, '-|', 'ps', '-eo', 'pid=,ppid=,args=') or return @pids;
    while (my $line = <$ps>) {
        chomp $line;
        next unless $line =~ /^\s*(\d+)\s+(\d+)\s+(.*)$/;
        my ($pid, $ppid, $cmd) = ($1, $2, $3);
        next if $pid == $$;
        next if $seen{$pid}++;

        if ($cmd =~ /run_sas_codes_or_(?:script|files)_in_ODA\.pl/) {
            next if $cmd =~ /--kill-saspy-sessions|--kill-sas-oda-sessions|--kill-saspy-session-server/;
            next unless $cmd =~ m{(?:^|/|\s)perl(?:\s|$)};
            push @pids, int($pid);
            next;
        }
        if ($cmd =~ /DiffGWASDeps\/sas_oda_session_server\.py/) {
            next unless $cmd =~ m{(?:^|/|\s)python[0-9.]*(?:\s|$)};
            push @pids, int($pid);
            next;
        }
        if ($cmd =~ /pyiom\.saspy2j/) {
            next unless $cmd =~ m{(?:^|/|\s)java(?:\s|$)};
            push @pids, int($pid);
            next;
        }
    }
    close $ps;
    return @pids;
}

sub kill_saspy_session_processes {
    my @pids = collect_sas_oda_session_pids();
    if (!@pids) {
        print "No active SAS ODA wrapper, session server, or SASPy Java bridge processes found.\n";
        return 0;
    }

    print "Stopping local SAS ODA wrapper/session processes: @pids\n";
    kill 'TERM', @pids;
    select undef, undef, undef, 2.0;

    my %wanted = map { $_ => 1 } @pids;
    my @still_running;
    for my $pid (@pids) {
        next unless $wanted{$pid};
        push @still_running, $pid if kill 0, $pid;
    }
    if (@still_running) {
        print "Forcibly killing still-running SAS ODA wrapper/session processes: @still_running\n";
        kill 'KILL', @still_running;
    }
    print "SAS ODA wrapper/session cleanup requested.\n";
    return scalar(@pids);
}

if ($kill_saspy_sessions) {
    kill_saspy_session_processes();
    exit 0;
}

if (defined $persistent && $persistent && !defined $session_id) {
    $session_id = "default_session";
    print STDERR "INFO: Persistent session requested but no session id provided; using default session id '$session_id'.",
    "\nPlease re-run with --session-id <id> to specify a session name, or omit --persistent to create a new session for this run only.\n";
}

if (defined $cli_sas_run_timeout_seconds) {
    $sas_run_timeout_seconds = int($cli_sas_run_timeout_seconds);
}
if (defined $cli_sas_run_timeout_grace_seconds) {
    $sas_run_timeout_grace_seconds = int($cli_sas_run_timeout_grace_seconds);
}
if ($disable_run_timeout) {
    $sas_run_timeout_seconds = 0;
}
$sas_run_timeout_seconds = 0 if $sas_run_timeout_seconds < 0;
$sas_run_timeout_grace_seconds = 0 if $sas_run_timeout_grace_seconds < 0;
$ENV{SAS_ODA_RUN_TIMEOUT_SECONDS} = $sas_run_timeout_seconds;
$ENV{SAS_ODA_RUN_TIMEOUT_GRACE_SECONDS} = $sas_run_timeout_grace_seconds;
$monitor_interval_seconds = defined($monitor_interval_seconds) ? int($monitor_interval_seconds) : 5;
$monitor_interval_seconds = 1 if $monitor_interval_seconds < 1;

# Treat an explicit session id as an intent to reuse a persistent SAS ODA
# session, even if the caller forgot to also pass --persistent.
if ($session_id) {
    $persistent = 1 unless defined $persistent;
}
if ($internal_session_id) {
    $internal_persistent = 1 unless defined $internal_persistent;
}

my $sas_oda_auth_bootstrap_done = 0;

sub env_truthy {
    my ($value) = @_;
    return 0 unless defined $value;
    return $value =~ /^(?:1|true|yes|y|on)$/i ? 1 : 0;
}

sub sas_oda_authkey_name {
    return $ENV{SASPY_ODA_AUTHKEY} || 'oda';
}

sub resolve_home_dir {
    for my $cand ($ENV{HOME}, $ENV{USERPROFILE}, getcwd()) {
        next unless defined $cand && length $cand;
        return $cand;
    }
    return '.';
}

sub resolve_sas_oda_authinfo_path {
    my $home = resolve_home_dir();
    my @existing = grep { -f $_ } (
        File::Spec->catfile($home, '.authinfo'),
        File::Spec->catfile($home, '_authinfo'),
    );
    return $existing[0] if @existing;
    return File::Spec->catfile($home, '.authinfo');
}

sub slurp_stdin_text {
    local $/;
    my $text = <STDIN>;
    return defined $text ? $text : '';
}

sub normalize_cli_code_text {
    my ($text) = @_;
    return '' unless defined $text;
    $text =~ s/\\r\\n/\n/g;
    $text =~ s/\\n/\n/g;
    $text =~ s/\\r/\r/g;
    $text =~ s/\\t/\t/g;
    return $text;
}

sub authinfo_entry_exists_for_key {
    my ($path, $authkey) = @_;
    return 0 unless defined $path && length $path && -f $path;
    open my $fh, '<', $path or return 0;
    while (my $line = <$fh>) {
        next if $line =~ /^\s*#/;
        next if $line !~ /\S/;
        if ($line =~ /^\s*\Q$authkey\E\s+user\s+\S+\s+password\s+\S+/i) {
            close $fh;
            return 1;
        }
    }
    close $fh;
    return 0;
}

sub authinfo_entry_user_for_key {
    my ($path, $authkey) = @_;
    return '' unless defined $path && length $path && -f $path;
    open my $fh, '<', $path or return '';
    while (my $line = <$fh>) {
        next if $line =~ /^\s*#/;
        if ($line =~ /^\s*\Q$authkey\E\s+user\s+(\S+)\s+password\s+\S+/i) {
            close $fh;
            return $1;
        }
    }
    close $fh;
    return '';
}

sub prompt_line_stderr {
    my ($prompt, $default) = @_;
    my $suffix = defined($default) && length($default) ? " [$default]" : '';
    print STDERR $prompt . $suffix . ': ';
    my $value = <STDIN>;
    die "SAS ODA credential entry cancelled before reading input.\n" unless defined $value;
    chomp $value;
    return length($value) ? $value : ($default // '');
}

sub prompt_password_stderr {
    my ($prompt) = @_;
    my $hidden = 0;
    print STDERR $prompt . ': ';
    if (-t STDIN && -t STDERR) {
        $hidden = system('stty', '-echo') == 0 ? 1 : 0;
    }
    my $value = <STDIN>;
    if ($hidden) {
        system('stty', 'echo');
        print STDERR "\n";
    }
    die "SAS ODA credential entry cancelled before reading password.\n" unless defined $value;
    chomp $value;
    return $value;
}

sub upsert_sas_oda_authinfo_entry {
    my (%args) = @_;
    my $path = $args{path};
    my $authkey = $args{authkey};
    my $account = $args{account};
    my $password = $args{password};
    die "Missing authinfo path\n" unless defined $path && length $path;
    die "Missing authkey\n" unless defined $authkey && length $authkey;
    die "Missing SAS ODA account\n" unless defined $account && length $account;
    die "Missing SAS ODA password\n" unless defined $password && length $password;

    my @lines;
    if (-f $path) {
        open my $fh, '<', $path or die "Cannot read $path: $!\n";
        @lines = <$fh>;
        close $fh;
    }

    my $entry = "$authkey user $account password $password\n";
    my $matched = 0;
    for my $line (@lines) {
        next unless $line =~ /^\s*\Q$authkey\E\s+user\b/i;
        $line = $entry;
        $matched = 1;
    }
    push @lines, $entry unless $matched;

    my $parent = dirname($path);
    if (defined $parent && length $parent && $parent ne '.' && !-d $parent) {
        make_path($parent);
    }
    open my $fh, '>', $path or die "Cannot write $path: $!\n";
    print {$fh} @lines;
    close $fh;
    chmod 0600, $path;
}

sub validate_sas_oda_login_once {
    my ($label) = @_;
    my ($fh, $script_path) = tempfile('sas_oda_login_probe_XXXX', SUFFIX => '.py', UNLINK => 1);
    print {$fh} <<'PY';
import json
import os
import sys
import saspy

def iter_cfg_names():
    preferred = os.environ.get('SASPY_CFGNAME') or os.environ.get('SASPY_CONFIG_NAME') or 'oda'
    seen = set()
    for name in (preferred, 'oda', 'default'):
        if not name or name in seen:
            continue
        seen.add(name)
        yield name

def main():
    last_error = None
    for cfgname in iter_cfg_names():
        sess = None
        try:
            sess = saspy.SASsession(cfgname=cfgname, results='html')
            res = sess.submit("proc setinit;run;")
            log = res.get('LOG', '') or ''
            ok = ('ERROR:' not in log and 'FATAL' not in log)
            print(json.dumps({
                'ok': bool(ok),
                'cfgname': cfgname,
                'log': log[-4000:],
            }))
            return 0 if ok else 3
        except Exception as exc:
            last_error = f"{type(exc).__name__}: {exc}"
        finally:
            if sess is not None:
                try:
                    sess.endsas()
                except Exception:
                    pass
    print(json.dumps({
        'ok': False,
        'error': last_error or 'Unable to create a SAS ODA session',
    }))
    return 2

if __name__ == '__main__':
    sys.exit(main())
PY
    close $fh;

    local $ENV{PYTHONPATH} = resolve_pythonpath() unless defined $ENV{PYTHONPATH} && length $ENV{PYTHONPATH};
    my $cmd = join(' ', sh_quote($python_bin), sh_quote($script_path), '2>&1');
    my $raw = qx{$cmd};
    my $status = $? >> 8;
    my $parsed;
    for my $line (reverse split /\r?\n/, $raw) {
        next unless defined $line && $line =~ /^\s*\{/;
        eval {
            $parsed = decode_json($line);
            1;
        } and last;
    }
    $parsed ||= {};
    $parsed->{status} = $status;
    $parsed->{raw_output} = $raw;
    $parsed->{ok} = $parsed->{ok} ? 1 : 0;
    $parsed->{label} = $label if defined $label && length $label;
    return $parsed;
}

sub bootstrap_sas_oda_credentials_if_needed {
    return if $sas_oda_auth_bootstrap_done;
    return if env_truthy($skip_sas_oda_auth_bootstrap) || env_truthy($ENV{PIPELINE_SKIP_SAS_ODA_AUTH_BOOTSTRAP});

    my $authkey = sas_oda_authkey_name();
    my $authinfo_path = resolve_sas_oda_authinfo_path();
    my $provided_account = defined($sas_oda_account) && length($sas_oda_account)
        ? $sas_oda_account
        : (defined($ENV{PIPELINE_SAS_ODA_ACCOUNT}) ? $ENV{PIPELINE_SAS_ODA_ACCOUNT} : '');
    my $provided_password = defined($sas_oda_password) && length($sas_oda_password)
        ? $sas_oda_password
        : (defined($ENV{PIPELINE_SAS_ODA_PASSWORD}) ? $ENV{PIPELINE_SAS_ODA_PASSWORD} : '');
    my $existing_entry = authinfo_entry_exists_for_key($authinfo_path, $authkey);
    my $existing_user = authinfo_entry_user_for_key($authinfo_path, $authkey);
    my $has_supplied_creds = length($provided_account) || length($provided_password);
    my $supplied_matches_existing_user = $existing_entry && length($provided_account) && $provided_account eq $existing_user;
    my $needs_bootstrap = (!$existing_entry)
        || (env_truthy($force_sas_oda_auth_prompt) || env_truthy($ENV{PIPELINE_FORCE_SAS_ODA_AUTH_PROMPT}))
        || ($has_supplied_creds && !$supplied_matches_existing_user);

    if (!$needs_bootstrap) {
        $sas_oda_auth_bootstrap_done = 1;
        return;
    }

    my $original_contents = '';
    if (-f $authinfo_path) {
        open my $orig, '<', $authinfo_path or die "Cannot read existing auth file $authinfo_path: $!\n";
        local $/;
        $original_contents = <$orig>;
        close $orig;
    }
    my $had_original_file = -f $authinfo_path ? 1 : 0;

    my $interactive = (-t STDIN && -t STDERR) ? 1 : 0;
    my $max_attempts = $has_supplied_creds ? 1 : ($interactive ? 3 : 1);
    for my $attempt (1 .. $max_attempts) {
        my $account = $provided_account;
        my $password = $provided_password;

        if (!length($account)) {
            die "SAS ODA credentials are not configured yet. Re-run interactively, or supply them with --sas-oda-account/--sas-oda-password (or PIPELINE_SAS_ODA_ACCOUNT / PIPELINE_SAS_ODA_PASSWORD).\n"
                unless $interactive;
            print STDERR "SAS ODA credentials were not found for authkey '$authkey'.\n";
            $account = prompt_line_stderr('Enter your SAS ODA account/email', $existing_user);
        }
        if (!length($password)) {
            die "The SAS ODA password was not provided. Re-run interactively, or supply it with --sas-oda-password (or PIPELINE_SAS_ODA_PASSWORD).\n"
                unless $interactive;
            $password = prompt_password_stderr('Enter your SAS ODA password');
        }

        upsert_sas_oda_authinfo_entry(
            path     => $authinfo_path,
            authkey  => $authkey,
            account  => $account,
            password => $password,
        );

        my $probe = validate_sas_oda_login_once('proc setinit');
        if ($probe->{ok}) {
            print STDERR "SAS ODA login validation succeeded with proc setinit;run; using authkey '$authkey'.\n";
            print STDERR "Saved the SAS ODA account/password to $authinfo_path. You do not need to supply them again unless they change.\n";
            $sas_oda_auth_bootstrap_done = 1;
            return;
        }

        if ($had_original_file) {
            open my $restore, '>', $authinfo_path or die "Cannot restore $authinfo_path after failed SAS ODA validation: $!\n";
            print {$restore} $original_contents;
            close $restore;
            chmod 0600, $authinfo_path;
        } else {
            unlink $authinfo_path if -f $authinfo_path;
        }

        my $detail = $probe->{error} || $probe->{raw_output} || 'unknown SAS ODA validation failure';
        chomp $detail;
        warn "WARNING: SAS ODA login validation failed. The supplied account or password may be wrong.\n";
        warn "Validation detail: $detail\n" if length $detail;

        if ($attempt < $max_attempts && $interactive) {
            print STDERR "Please try entering the SAS ODA account/password again.\n";
            $provided_account = '';
            $provided_password = '';
            next;
        }

        die "SAS ODA login validation failed. The supplied account or password may be wrong. Credentials were not saved.\n";
    }
}

if ($internal_runner_result_json) {
    bootstrap_sas_oda_credentials_if_needed();
    my $worker_runner = SAS_ODA_Runner->new(
        local_macro_dir => $internal_macro_dir || "./",
        open_html       => defined($internal_open_html) ? $internal_open_html : 1,
        session_id      => $internal_session_id,
        persistent      => $internal_persistent,
    );
    my $worker_result;
    my $worker_error = '';
    eval {
        if ($internal_execution_file) {
            $worker_result = $worker_runner->run_file($internal_execution_file);
        } elsif ($internal_execution_code_file) {
            my $worker_code = slurp_text_file($internal_execution_code_file);
            $worker_result = $worker_runner->run_code($worker_code);
        } else {
            die "Internal worker received neither execution file nor code file";
        }
        1;
    } or do {
        $worker_error = $@ || 'unknown internal worker error';
    };
    if ($worker_error) {
        $worker_result = {
            error    => $worker_error,
            log      => '',
            lst      => '',
            dep_logs => '',
            output   => '',
            htmlfilename => '',
        };
    }
    open my $worker_out, '>', $internal_runner_result_json
      or die "Cannot write internal worker result to $internal_runner_result_json: $!\n";
    print {$worker_out} encode_json({
        eval_error => $worker_error,
        result     => make_json_safe($worker_result),
    });
    close $worker_out;
    exit(($worker_error || (ref($worker_result) eq 'HASH' && ($worker_result->{error} // ''))) ? 1 : 0);
}

if ($help || (!$check_sas_oda_login_only && !$monitor_status_file && !$code && !$file && !@upload_files && !@download_files && !@delete_files && !@delete_file_rgxs && !$dir4listing && !@file_infos)
   || ($code && $file) ) {
    print <<USAGE;
Usage: $0 [OPTIONS]

Options:
  -c, --code, --codes <code> SAS code string to execute.
                             Pass '-' to read SAS code from STDIN, which is
                             the most reliable way to submit raw DATALINES/CARDS
                             blocks or other multi-line code from the shell.
                             Literal '\n', '\r\n', and '\t' sequences in a
                             direct --code string are expanded before submit.
  -f, --file <file>          SAS script file to execute
  -m, --macro-dir <dir>      Directory containing macro files (default: ./)
  --no-html-info             output a plain text file containing the random html filename
  -p, --output-prefix <prefix> Prefix for output files (default: output)
    --persistent             Keep SAS session alive for multiple runs, only working with --session-id. If not specified, a new session is created and destroyed for each run.
                             As the intial starting of saspy server and sas oda session takes time, using persistent session can save time for multiple runs. So please try to
                             use persistent session with --session-id for multiple runs. If you want to run a single SAS code or script, you can skip using persistent session.
  -s, --session-id <id>      Reuse existing persistent session, better supplied wwith --persistent. If not specified, a new session is created and destroyed for each run.
                             On new session creation, the runner auto-loads macros from '~/Macros'
                             once via importallmacros_ue. Reused sessions do not rerun that import.
  -u, --upload-file <file>   Upload a file to remote SAS ODA HOME directory.
                             Repeat this option to upload multiple files in one run.
      --skip-upload-if-same  Reuse an existing remote file with the same basename
                             when size and timestamp already match (default: on).
                             Pass --no-skip-upload-if-same to force a fresh upload.
  -d, --download-file <file> Download a remote file from SAS ODA.
                             Repeat this option to download multiple files in one run.
      --download-local-path  Explicit local destination path for --download-file.
                             Repeat to pair paths positionally with repeated --download-file.
                             If omitted, downloads default to the current directory.
  --delete-file <file>       Delete a remote file by name/path.
                             Repeat this option to delete multiple files in one run.
  --delete-file-rgx <regex>  Delete every remote file whose basename matches the regex.
                             Repeat this option to apply multiple regex patterns.
      --delete-dir <dir>     Remote directory to scan for --delete-file-rgx matches
                             (default: '~')
  --dir4listing              list out files in remote directory in SAS ODA, 
                             such as '~/Macros', remember to restrict it to eval using single quote
  --file-info <file>         Return remote file existence, size, and timestamp metadata.
                             Repeat this option to inspect multiple files.
                             Quote '~/...' in your shell so the local shell does not
                             expand the remote HOME shorthand before this helper sees it.
  --sas-oda-account <user>   Optional SAS ODA account/email for first-run credential bootstrap.
  --sas-oda-password <pass>  Optional SAS ODA password for first-run credential bootstrap.
  --prompt-sas-oda-auth      Force an interactive SAS ODA credential refresh before connecting.
  --check-sas-oda-login-only Validate SAS ODA login with PROC SETINIT and exit.
  --monitor-status-file <f>  Follow a live SAS ODA status JSON sidecar from another terminal.
  --monitor-interval-seconds <n>
                             Poll interval for --monitor-status-file (default: 5 seconds).
  --kill-saspy-sessions      Stop active local SAS ODA wrapper jobs, session server,
                             and SASPy Java bridge processes, then exit. Use from
                             another terminal when a persistent SASPy/ODA session
                             is wedged.
  --run-timeout-seconds <n>  Override the overall submit timeout for this run.
                             Use 0 to disable the timeout completely.
  --run-timeout-grace-seconds <n>
                             Extra wait after TERM before forcible kill.
  --no-run-timeout           Disable the overall timeout for this run.
  --dry-run                  Print resolved session settings and exit (no SAS execution)
  -h, --help                 Show this help message

Environment:
  SAS_ODA_RUN_TIMEOUT_SECONDS        Overall timeout for submit and file-transfer helper actions
                                     in this wrapper (default: ${default_sas_run_timeout_seconds}s; set to 0 to disable)
  SAS_ODA_RUN_TIMEOUT_GRACE_SECONDS  Extra wait after TERM before forcible kill (default: ${sas_run_timeout_grace_seconds}s)
  SAS_ODA_SESSION_SUBMIT_TIMEOUT_SECONDS
                                     Optional persistent session-server response timeout.
                                     If unset, it follows SAS_ODA_RUN_TIMEOUT_SECONDS; set 0 to disable.

Examples:
  $0 --upload-file mydata.csv --upload-file myplot.png --persistent --session-id mysession
  $0 --upload-file mydata.csv --no-skip-upload-if-same --persistent --session-id mysession
  $0 --download-file '~/my.file.txt' --download-local-path ./my.file.txt --persistent --session-id mysession
  $0 --download-file '~/a.txt' --download-file '~/b.txt' --download-local-path ./a.txt --download-local-path ./b.txt
  $0 --dir4listing '~/Macros' --persistent --session-id mysession
  $0 --delete-file my.file.txt --delete-file old.log --persistent --session-id mysession
  $0 --delete-file-rgx '^tmp_.*\\.sas\$' --delete-dir '~' --persistent --session-id mysession
  $0 --file-info '~/big.tsv.gz' --file-info '~/plot.png' --persistent --session-id mysession
  $0 --kill-saspy-sessions
  $0 --code "proc print data=sashelp.class; run;" --persistent --session-id mysession
  $0 --file long_job.sas --run-timeout-seconds 7200 --persistent --session-id mysession
  $0 --file very_long_job.sas --no-run-timeout --persistent --session-id mysession
  $0 --code 'data a;do i=1 to 1000;x=i**2;output;rc=sleep(1);end;run;proc print data=a(obs=10);run
;' --no-run-timeout --persistent --session-id mysession
  $0 --code "data a;input a @@;datalines;\n10 20\n;run;proc print data=a;run;" --persistent --session-id mysession
  ./run_sas_codes_or_script_in_ODA.pl --code 'data a;input a @@;datalines;\n10 20\n;run;proc print;run; ' --persistent --session-id ms1
  $0 --file script1.sas --persistent --session-id mysession
  $0 --file script2.sas --session-id mysession
  perl -S run_sas_codes_or_script_in_ODA.pl   --code "data a; set sashelp.cars; run;"   --persistent --session-id reuse_test --output-prefix reuse1
  #Note: the above command creates a session "reuse_test" and runs code to create dataset "a". The next command reuses the same session to print dataset "a".
  #Macros in ~/Macros are auto-imported only when the session is created; they are not re-imported on reuse.
  #both --persistent and --session-id must be used together to enable session reuse. The output files will have prefixes "reuse1" and "reuse2" respectively.
  perl -S run_sas_codes_or_script_in_ODA.pl   --code "proc print data=a; run;"   --persistent --session-id reuse_test --output-prefix reuse2
  printf '%s\\n' \\
    'data a;' \\
    'input a @@;' \\
    'datalines;' \\
    '10 20' \\
    ';' \\
    'run;' \\
    'proc print data=a;' \\
    'run;' |
  $0 --code - --persistent --session-id mysession
USAGE
    exit 0;
}

# Dry-run mode: print resolved session settings and exit (no SAS required)
if ($dry_run) {
    # If a session id is provided, enable persistent mode so the session can be reused.
    if ($session_id) {
        $persistent = 1 unless defined $persistent;
    }
    # Default session id when persistent mode is requested but none provided
    $session_id ||= "default_session" if $persistent;
    print "DRY-RUN: persistent=" . ($persistent ? 1 : 0) . " session_id=" . ($session_id // '(undef)') . "\n";
    exit 0;
}

if ($monitor_status_file) {
    monitor_status_loop($monitor_status_file, $monitor_interval_seconds);
    exit 0;
}

if (defined $code && $code eq '-') {
    $code = slurp_stdin_text();
} elsif (defined $code) {
    $code = normalize_cli_code_text($code);
}

bootstrap_sas_oda_credentials_if_needed();

if ($check_sas_oda_login_only) {
    my $probe = validate_sas_oda_login_once('proc setinit');
    if ($probe->{ok}) {
        print "SAS ODA login validation succeeded with proc setinit;run;\n";
        exit 0;
    }
    my $detail = $probe->{error} || $probe->{raw_output} || 'unknown SAS ODA validation failure';
    die "SAS ODA login validation failed: $detail\n";
}

die "Error: Cannot provide both --code and --file\n" if $code && $file;
die "Error: File '$file' does not exist\n" if $file && !-e $file;
for my $upload_path (@upload_files) {
    die "Error: Upload file '$upload_path' does not exist\n" if !-e $upload_path;
}
if (@download_local_paths && @download_files > 1 && @download_local_paths != @download_files) {
    die "Error: When downloading multiple files, provide either zero or the same number of --download-local-path values.\n";
}

sub ensure_output_dir {
    my ($dir) = @_;
    return if !$dir || -d $dir;
    make_path($dir);
    die "Cannot create directory $dir: $!\n" if !-d $dir;
    $created_output_dir = 1;
}

sub cleanup_empty_output_dir_if_created {
    my ($dir) = @_;
    return unless $created_output_dir;
    return unless defined $dir && length $dir && -d $dir;
    opendir(my $dh, $dir) or return;
    my @entries = grep { $_ ne '.' && $_ ne '..' } readdir($dh);
    closedir $dh;
    return if @entries;
    rmdir $dir;
}

sub read_status_file {
    my ($path) = @_;
    return unless defined $path && length $path && -e $path;
    open my $fh, '<:encoding(UTF-8)', $path or return;
    local $/;
    my $raw = <$fh>;
    close $fh;
    return unless defined $raw && $raw =~ /\S/;
    $raw =~ s/^\x{FEFF}//;
    my $data = eval { decode_json($raw) };
    return $data if ref($data) eq 'HASH';
    return;
}

sub write_status_file {
    my ($path, $update_ref) = @_;
    return unless defined $path && length $path;
    $update_ref ||= {};
    my $data = read_status_file($path) || {};
    for my $key (keys %{$update_ref}) {
        $data->{$key} = $update_ref->{$key};
    }
    $data->{last_update} = status_timestamp();
    $data->{last_update_epoch} = time();
    my $dir = dirname($path);
    ensure_output_dir($dir) if defined $dir && length $dir;
    my $tmp = "$path.tmp";
    open my $fh, '>:encoding(UTF-8)', $tmp or die "Cannot write status file $tmp: $!\n";
    print {$fh} encode_json($data);
    close $fh;
    rename $tmp, $path or die "Cannot rename $tmp to $path: $!\n";
}

sub summarize_status_hash {
    my ($data) = @_;
    return '' unless ref($data) eq 'HASH';
    my @lines;
    for my $key (qw(state phase message bootstrap_started_at bootstrap_finished_at bootstrap_elapsed_seconds bootstrap_ok bootstrap_warning bootstrap_log_path last_update)) {
        next unless exists $data->{$key};
        my $value = $data->{$key};
        next unless defined $value && $value ne '';
        push @lines, "$key: $value";
    }
    return join("\n", @lines);
}

sub format_status_line {
    my ($data) = @_;
    return '' unless ref($data) eq 'HASH';
    my @parts;
    push @parts, ($data->{last_update} // status_timestamp());
    push @parts, '[' . ($data->{state} // 'unknown') . ']';
    push @parts, ($data->{phase} // 'status');
    push @parts, '-';
    push @parts, ($data->{message} // '');
    if (defined $data->{elapsed_seconds} && $data->{elapsed_seconds} =~ /^\d+$/) {
        push @parts, '(elapsed ' . $data->{elapsed_seconds} . 's)';
    }
    return join(' ', grep { defined $_ && length $_ } @parts);
}

sub monitor_status_loop {
    my ($path, $interval) = @_;
    $interval = 5 unless defined $interval && $interval > 0;
    my $old = select(STDOUT);
    $| = 1;
    select($old);
    print "Monitoring status file: $path\n";
    my $last_fingerprint = '';
    my $announced_wait = 0;
    while (1) {
        my $data = read_status_file($path);
        if (ref($data) eq 'HASH') {
            my $fingerprint = join(
                "\t",
                map { defined($data->{$_}) ? $data->{$_} : '' }
                  qw(last_update state phase message elapsed_seconds complete success)
            );
            if ($fingerprint ne $last_fingerprint) {
                print format_status_line($data) . "\n";
                $last_fingerprint = $fingerprint;
            }
            if ($data->{complete}) {
                print "Monitor finished: " . (($data->{success}) ? 'success' : 'failure') . "\n";
                last;
            }
            $announced_wait = 1;
        } else {
            if (!$announced_wait) {
                print "Waiting for status file to be created...\n";
                $announced_wait = 1;
            }
        }
        sleep $interval;
    }
}

sub kill_process_tree {
    my ($pid) = @_;
    return unless $pid && $pid > 0;

    kill 'TERM', $pid;
    select undef, undef, undef, 0.5;
    kill 'KILL', $pid;

    if ($^O =~ /^(?:MSWin32|cygwin)$/i) {
        system('cmd', '/c', "taskkill /PID $pid /T /F >NUL 2>NUL");
    }
}

sub make_json_safe {
    my ($value) = @_;
    if (!ref($value)) {
        return $value;
    }
    if (ref($value) eq 'HASH') {
        my %copy;
        for my $key (keys %{$value}) {
            $copy{$key} = make_json_safe($value->{$key});
        }
        return \%copy;
    }
    if (ref($value) eq 'ARRAY') {
        return [ map { make_json_safe($_) } @{$value} ];
    }
    if (blessed($value) && ($value->isa('JSON::PP::Boolean') || $value->isa('JSON::XS::Boolean'))) {
        return $value ? 1 : 0;
    }
    if (blessed($value) && overload::Method($value, q{""})) {
        return "$value";
    }
    if (blessed($value) && overload::Method($value, q{0+})) {
        return 0 + $value;
    }
    return "$value";
}

sub run_sas_submit_with_timeout {
    my ($label, $code_ref) = @_;
    return $code_ref->() if !$sas_run_timeout_seconds || $sas_run_timeout_seconds <= 0;

    my ($tmpfh, $tmpjson) = tempfile('sas_submit_result_XXXX', SUFFIX => '.json', UNLINK => 0, DIR => getcwd());
    close $tmpfh;
    my $debug_sidecar = $tmpjson . '.debug.txt';

    my $pid = fork();
    die "Could not fork for timed SAS submit\n" unless defined $pid;

    if ($pid == 0) {
        my $result;
        my $eval_error = '';
        eval {
            $result = $code_ref->();
            1;
        } or do {
            $eval_error = $@ || 'unknown timed submit error';
        };

        if ($ENV{SAS_ODA_DEBUG_RESULT_SUMMARY}) {
            if (open(my $dbg, '>', $debug_sidecar)) {
                if (ref($result) eq 'HASH') {
                    my $log_len = defined($result->{log}) ? length($result->{log}) : -1;
                    my $lst_len = defined($result->{lst}) ? length($result->{lst}) : -1;
                    my $html_len = defined($result->{htmlfilename}) ? length($result->{htmlfilename}) : -1;
                    print {$dbg} "child_result_hash log_len=$log_len lst_len=$lst_len htmlfilename_len=$html_len error=" .
                                 (defined($result->{error}) ? $result->{error} : '') . "\n";
                } else {
                    print {$dbg} "child_result_ref=" . (defined($result) ? ref($result) || 'scalar' : 'undef') . "\n";
                }
                print {$dbg} "child_eval_error=$eval_error\n" if length $eval_error;
                close $dbg;
            }
        }

        if (open(my $out, '>', $tmpjson)) {
            print {$out} encode_json({
                eval_error => $eval_error,
                result     => make_json_safe($result),
            });
            close $out;
        }
        exit($eval_error ? 1 : 0);
    }

    my $start = time();
    my $reaped = 0;
    my $timed_out = 0;
    while (1) {
        my $wp = waitpid($pid, WNOHANG);
        if ($wp == $pid || $wp == -1) {
            $reaped = 1;
            last;
        }
        if ((time() - $start) >= $sas_run_timeout_seconds) {
            $timed_out = 1;
            last;
        }
        sleep 1;
    }

    if ($timed_out) {
        warn "Warning: $label exceeded ${sas_run_timeout_seconds}s; terminating the SAS submit process tree.\n";
        kill_process_tree($pid);
        my $deadline = time() + ($sas_run_timeout_grace_seconds > 0 ? $sas_run_timeout_grace_seconds : 1);
        while (time() < $deadline) {
            my $wp = waitpid($pid, WNOHANG);
            if ($wp == $pid || $wp == -1) {
                $reaped = 1;
                last;
            }
            sleep 1;
        }
        waitpid($pid, 0) unless $reaped;
        unlink $tmpjson if -e $tmpjson;
        return {
            error => "$label timed out after ${sas_run_timeout_seconds}s",
            log   => '',
            lst   => '',
            dep_logs => '',
        };
    }

    my $payload;
    if (-s $tmpjson && open(my $in, '<', $tmpjson)) {
        local $/;
        my $raw = <$in>;
        close $in;
        eval { $payload = decode_json($raw) if defined $raw && length $raw; };
    }
    unlink $tmpjson if -e $tmpjson;
    if ($ENV{SAS_ODA_DEBUG_RESULT_SUMMARY} && -e $debug_sidecar) {
        if (open(my $dbg, '<', $debug_sidecar)) {
            local $/;
            my $dbg_text = <$dbg>;
            close $dbg;
            warn "DEBUG: timeout-wrapper child summary for $label:\n$dbg_text";
        }
        unlink $debug_sidecar;
    }

    if (!$payload) {
        return {
            error => "$label ended without a readable result payload",
            log   => '',
            lst   => '',
            dep_logs => '',
        };
    }
    if (defined($payload->{eval_error}) && length($payload->{eval_error})) {
        return {
            error => $payload->{eval_error},
            log   => '',
            lst   => '',
            dep_logs => '',
        };
    }
    return $payload->{result};
}

sub run_scalar_action_with_timeout {
    my ($label, $code_ref) = @_;
    return $code_ref->() if !$sas_run_timeout_seconds || $sas_run_timeout_seconds <= 0;

    my $wrapped = run_sas_submit_with_timeout($label, sub {
        return {
            __codex_timeout_wrapper_type => 'scalar',
            value => scalar($code_ref->()),
        };
    });

    if (ref($wrapped) eq 'HASH' && ($wrapped->{__codex_timeout_wrapper_type} // '') eq 'scalar') {
        return $wrapped->{value};
    }
    if (ref($wrapped) eq 'HASH' && defined($wrapped->{error}) && length($wrapped->{error})) {
        return "PYTHON ERROR: $wrapped->{error}";
    }
    return $wrapped;
}

sub run_hash_action_with_timeout {
    my ($label, $code_ref) = @_;
    return $code_ref->() if !$sas_run_timeout_seconds || $sas_run_timeout_seconds <= 0;

    my $wrapped = run_sas_submit_with_timeout($label, sub {
        return {
            __codex_timeout_wrapper_type => 'hash',
            value => $code_ref->(),
        };
    });

    if (ref($wrapped) eq 'HASH' && ($wrapped->{__codex_timeout_wrapper_type} // '') eq 'hash') {
        return $wrapped->{value};
    }
    if (ref($wrapped) eq 'HASH' && defined($wrapped->{error}) && length($wrapped->{error})) {
        return $wrapped->{error};
    }
    return $wrapped;
}

sub run_array_action_with_timeout {
    my ($label, $code_ref) = @_;
    return $code_ref->() if !$sas_run_timeout_seconds || $sas_run_timeout_seconds <= 0;

    my $wrapped = run_sas_submit_with_timeout($label, sub {
        return {
            __codex_timeout_wrapper_type => 'array',
            value => $code_ref->(),
        };
    });

    if (ref($wrapped) eq 'HASH' && ($wrapped->{__codex_timeout_wrapper_type} // '') eq 'array') {
        return $wrapped->{value};
    }
    if (ref($wrapped) eq 'HASH' && defined($wrapped->{error}) && length($wrapped->{error})) {
        return $wrapped->{error};
    }
    return $wrapped;
}

# Create output directory name with random ID
my $rand_id = int(rand(999999)) + 1000;
my $output_dir = ($output_prefix || "SAS_Output" . "_RandID" . $rand_id);
my $output_prefix_path = "$output_dir/output";
my $status_file = "$output_prefix_path.run.status.json";

$ENV{SAS_ODA_STATUS_FILE} = File::Spec->rel2abs($status_file);

my $runner = SAS_ODA_Runner->new(
    local_macro_dir => $macro_dir || "./",
    open_html => !$no_html,
    session_id => $session_id,
    persistent => $persistent,
);

sub make_runner {
    my (%overrides) = @_;
    return SAS_ODA_Runner->new(
        local_macro_dir => $overrides{local_macro_dir} // ($macro_dir || "./"),
        open_html       => $overrides{open_html} // (!$no_html),
        session_id      => exists $overrides{session_id} ? $overrides{session_id} : $session_id,
        persistent      => exists $overrides{persistent} ? $overrides{persistent} : $persistent,
    );
}

sub is_retryable_transport_error {
    my ($value) = @_;
    return 0 unless defined $value;
    return ($value =~ /(Broken pipe|cannot connect to session server|incomplete response|failed to read response (?:header|body) from session server|timed out waiting for session server response|session server request timed out|No SAS process attached|SAS process has terminated unexpectedly)/i) ? 1 : 0;
}

sub has_visible_content {
    my ($value) = @_;
    return 0 unless defined $value;
    return ($value =~ /\S/) ? 1 : 0;
}

sub fallback_runner {
    return make_runner(persistent => 0, session_id => undef);
}

sub persistent_submit_fallback_allowed {
    return env_truthy($ENV{SAS_ODA_ALLOW_PERSISTENT_SUBMIT_FALLBACK});
}

sub persistent_submit_fallback_notice {
    return "Persistent-session SAS submit fallback to a one-shot SAS connection is disabled, "
      . "because that would break session reuse semantics for WORK datasets and macro state. "
      . "Re-run the same session after fixing the persistent-session transport problem, or set "
      . "SAS_ODA_ALLOW_PERSISTENT_SUBMIT_FALLBACK=1 if you explicitly want the older one-shot retry behavior.";
}

sub run_with_possible_fallback {
    my ($action, $code_ref) = @_;
    my $result = run_scalar_action_with_timeout(
        "SAS ODA $action",
        sub { return $code_ref->($runner); },
    );
    if (defined $result
        && !ref($result)
        && $result =~ /^PYTHON ERROR:/
        && $persistent
        && $session_id) {
        if (is_retryable_transport_error($result)) {
            warn "Warning: persistent-session $action hit a known transport failure; retrying once with a one-shot SAS ODA connection.\n";
        } else {
            warn "Warning: persistent-session $action failed; retrying once with a one-shot SAS ODA connection.\n";
        }
        $result = run_scalar_action_with_timeout(
            "fallback SAS ODA $action",
            sub { return $code_ref->(fallback_runner()); },
        );
    }
    return $result;
}

sub run_hash_with_possible_fallback {
    my ($action, $code_ref) = @_;
    my $result = run_hash_action_with_timeout(
        "SAS ODA $action",
        sub { return $code_ref->($runner); },
    );
    if ((!ref($result) || ref($result) ne 'HASH')
        && $persistent
        && $session_id) {
        if (is_retryable_transport_error($result)) {
            warn "Warning: persistent-session $action hit a known transport failure; retrying once with a one-shot SAS ODA connection.\n";
        } else {
            warn "Warning: persistent-session $action failed; retrying once with a one-shot SAS ODA connection.\n";
        }
        $result = run_hash_action_with_timeout(
            "fallback SAS ODA $action",
            sub { return $code_ref->(fallback_runner()); },
        );
    }
    return $result;
}

sub run_array_with_possible_fallback {
    my ($action, $code_ref) = @_;
    my $result = run_array_action_with_timeout(
        "SAS ODA $action",
        sub { return $code_ref->($runner); },
    );
    if ((!ref($result) || ref($result) ne 'ARRAY')
        && $persistent
        && $session_id) {
        if (is_retryable_transport_error($result)) {
            warn "Warning: persistent-session $action hit a known transport failure; retrying once with a one-shot SAS ODA connection.\n";
        } else {
            warn "Warning: persistent-session $action failed; retrying once with a one-shot SAS ODA connection.\n";
        }
        $result = run_array_action_with_timeout(
            "fallback SAS ODA $action",
            sub { return $code_ref->(fallback_runner()); },
        );
    }
    return $result;
}

sub resolve_download_local_path {
    my ($index, $remote_path) = @_;
    my $resolved;
    if (@download_local_paths == 1 && @download_files == 1) {
        $resolved = $download_local_paths[0];
        return File::Spec->rel2abs($resolved);
    }
    if (@download_local_paths == @download_files && @download_local_paths) {
        $resolved = $download_local_paths[$index];
        return File::Spec->rel2abs($resolved);
    }
    my $leaf = basename($remote_path);
    $leaf =~ s{^~\/}{};
    return File::Spec->catfile(getcwd(), $leaf);
}

sub slurp_text_file {
    my ($path) = @_;
    return '' unless defined $path && length $path && -e $path;
    open my $fh, '<', $path or return '';
    local $/;
    my $text = <$fh>;
    close $fh;
    return defined $text ? $text : '';
}

sub run_runner_submit_with_timeout {
    my (%args) = @_;
    my $label = $args{label} // 'SAS submit';
    my $execution_file = $args{execution_file};
    my $execution_code = $args{execution_code};
    my $runner_obj = $args{runner};
    my $runner_macro_dir = $args{macro_dir} // "./";
    my $runner_open_html = defined($args{open_html}) ? $args{open_html} : 1;
    my $runner_persistent = $args{persistent} ? 1 : 0;
    my $runner_session_id = $args{session_id};

    if (!$sas_run_timeout_seconds || $sas_run_timeout_seconds <= 0) {
        return defined($execution_file)
          ? $runner_obj->run_file($execution_file)
          : $runner_obj->run_code($execution_code // '');
    }

    my ($tmpfh, $tmpjson) = tempfile('sas_submit_worker_result_XXXX', SUFFIX => '.json', UNLINK => 0, DIR => getcwd());
    close $tmpfh;

    my $code_file = '';
    if (!defined $execution_file) {
        my ($codefh, $tmpcode) = tempfile('sas_submit_worker_code_XXXX', SUFFIX => '.sas', UNLINK => 0, DIR => getcwd());
        print {$codefh} ($execution_code // '');
        close $codefh;
        $code_file = $tmpcode;
    }

    my $script_path = abs_path(__FILE__) || File::Spec->rel2abs(__FILE__);
    my @cmd = (
        $^X,
        $script_path,
        '--_internal-runner-result-json', $tmpjson,
        '--_internal-macro-dir', $runner_macro_dir,
        '--_internal-open-html=' . ($runner_open_html ? 1 : 0),
    );
    if (defined $execution_file) {
        push @cmd, ('--_internal-execution-file', $execution_file);
    } else {
        push @cmd, ('--_internal-execution-code-file', $code_file);
    }
    if ($runner_persistent) {
        push @cmd, '--_internal-persistent';
        push @cmd, ('--_internal-session-id', $runner_session_id) if defined $runner_session_id && length $runner_session_id;
    }

    my $pid = fork();
    die "Could not fork for timed SAS submit worker\n" unless defined $pid;

    if ($pid == 0) {
        local $ENV{SAS_ODA_RUN_TIMEOUT_SECONDS} = 0;
        local $ENV{SAS_ODA_RUN_TIMEOUT_GRACE_SECONDS} = 0;
        exec { $^X } @cmd;
        die "Could not exec internal SAS submit worker: $!\n";
    }

    my $reaped = 0;
    my $timed_out = 0;
    my $start = time();
    while (1) {
        my $wp = waitpid($pid, WNOHANG);
        if ($wp == $pid || $wp == -1) {
            $reaped = 1;
            last;
        }
        if ((time() - $start) >= $sas_run_timeout_seconds) {
            $timed_out = 1;
            last;
        }
        sleep 1;
    }

    if ($timed_out) {
        warn "Warning: $label exceeded ${sas_run_timeout_seconds}s; terminating the SAS submit process tree.\n";
        kill_process_tree($pid);
        my $deadline = time() + ($sas_run_timeout_grace_seconds > 0 ? $sas_run_timeout_grace_seconds : 1);
        while (time() < $deadline) {
            my $wp = waitpid($pid, WNOHANG);
            if ($wp == $pid || $wp == -1) {
                $reaped = 1;
                last;
            }
            sleep 1;
        }
        waitpid($pid, 0) unless $reaped;
        unlink $tmpjson if -e $tmpjson;
        unlink $code_file if $code_file && -e $code_file;
        return {
            error => "$label timed out after ${sas_run_timeout_seconds}s",
            log   => '',
            lst   => '',
            dep_logs => '',
        };
    }

    waitpid($pid, 0) unless $reaped;

    my $payload;
    if (-s $tmpjson && open(my $in, '<', $tmpjson)) {
        local $/;
        my $raw = <$in>;
        close $in;
        eval { $payload = decode_json($raw) if defined $raw && length $raw; };
    }
    unlink $tmpjson if -e $tmpjson;
    unlink $code_file if $code_file && -e $code_file;

    if (!$payload || ref($payload) ne 'HASH') {
        return {
            error => "$label ended without a readable worker result payload",
            log   => '',
            lst   => '',
            dep_logs => '',
        };
    }
    my $worker_result = $payload->{result};
    my $worker_eval_error = $payload->{eval_error} // '';
    if (!defined $worker_result || ref($worker_result) ne 'HASH') {
        return {
            error => (length($worker_eval_error) ? $worker_eval_error : "$label ended without a readable worker result payload"),
            log   => '',
            lst   => '',
            dep_logs => '',
        };
    }
    if (length($worker_eval_error) && !length($worker_result->{error} // '')) {
        $worker_result->{error} = $worker_eval_error;
    }
    return $worker_result;
}

sub sas_submission_contains_include {
    my ($text) = @_;
    return 0 unless defined $text && length $text;
    return ($text =~ /%include\b/i) ? 1 : 0;
}

sub is_builtin_macro_name {
    my ($name) = @_;
    return 1 unless defined $name && length $name;
    return $name =~ /^(?:let|put|do|else|end|if|then|abort|window|display|str|nrstr|bquote|nrbquote|superq|sysfunc|qsysfunc|scan|substr|upcase|lowcase|length|eval|sysevalf|quote|unquote|cmpres|sysprod|sysmacroname|global|local|mend|macro|goto|return|include)$/i ? 1 : 0;
}

sub sas_submission_uses_nonbuiltin_macro {
    my ($text) = @_;
    return 0 unless defined $text && length $text;
    my $scan = $text;
    $scan =~ s{/\*.*?\*/}{}gs;
    $scan =~ s{^\s*\*[^;]*;[ \t]*$}{}mg;
    while ($scan =~ /%(\w+)/g) {
        my $name = $1;
        next if is_builtin_macro_name($name);
        return 1;
    }
    return 0;
}

sub should_autoload_macros_for_submission {
    my ($text) = @_;
    return 1 if exists $ENV{SAS_ODA_AUTOLOAD_MACROS};
    return 1 if sas_submission_contains_include($text);
    return 1 if sas_submission_uses_nonbuiltin_macro($text);
    return 0;
}

sub extract_include_targets {
    my ($text) = @_;
    my @targets;
    return @targets unless defined $text && length $text;
    while ($text =~ /%include\s+(?:["'])([^"']+)(?:["'])/ig) {
        push @targets, $1 if defined $1 && length $1;
    }
    return @targets;
}

sub is_remote_include_path {
    my ($path) = @_;
    return 0 unless defined $path && length $path;
    return ($path =~ m{^(?:~/|/)}) ? 1 : 0;
}

sub resolve_local_include_path {
    my ($path) = @_;
    return '' unless defined $path && length $path;
    return $path if -e $path;
    my @candidates = (
        File::Spec->catfile(getcwd(), $path),
        File::Spec->catfile($macro_dir || './', $path),
        File::Spec->catfile(dirname(abs_path(__FILE__)), $path),
    );
    for my $candidate (@candidates) {
        next unless defined $candidate && length $candidate;
        return $candidate if -e $candidate;
    }
    my $base = basename($path);
    if (defined $base && length $base && $base ne $path) {
        my @roots = grep { defined $_ && length $_ && -d $_ } (
            getcwd(),
            ($macro_dir || './'),
            dirname(abs_path(__FILE__)),
        );
        my %seen_root;
        for my $root (@roots) {
            next if $seen_root{$root}++;
            my $found = '';
            find(
                {
                    no_chdir => 1,
                    wanted   => sub {
                        return unless -f $_;
                        return unless basename($_) eq $base;
                        $found = $File::Find::name;
                    },
                },
                $root,
            );
            return $found if $found && -e $found;
        }
    }
    return '';
}

sub format_line_number {
    my ($n) = @_;
    return sprintf('%6d', $n);
}

sub collapse_line_ranges {
    my ($lines_ref, $max_line) = @_;
    my %uniq;
    for my $line (@{$lines_ref || []}) {
        next unless defined $line && $line =~ /^\d+$/;
        next if $line < 1;
        next if defined $max_line && $line > $max_line;
        $uniq{$line} = 1;
    }
    my @lines = sort { $a <=> $b } keys %uniq;
    my @ranges;
    return @ranges unless @lines;
    my ($start, $prev) = ($lines[0], $lines[0]);
    for my $line (@lines[1 .. $#lines]) {
        if ($line == $prev + 1) {
            $prev = $line;
            next;
        }
        push @ranges, [ $start, $prev ];
        ($start, $prev) = ($line, $line);
    }
    push @ranges, [ $start, $prev ];
    return @ranges;
}

sub _blank_preserving_newlines {
    my ($text) = @_;
    $text //= '';
    $text =~ s/[^\n]/ /g;
    return $text;
}

sub sanitize_sas_text_for_macro_lint {
    my ($text) = @_;
    my $masked = defined($text) ? $text : '';
    $masked =~ s{/\*.*?\*/}{ _blank_preserving_newlines($&) }gse;
    $masked =~ s{(^\s*%\*[^;]*;)}{ _blank_preserving_newlines($1) }gme;
    $masked =~ s{(^\s*\*[^;]*;)}{ _blank_preserving_newlines($1) }gme;
    $masked =~ s{"(?:[^"]|"")*"}{ _blank_preserving_newlines($&) }gse;
    $masked =~ s{'(?:[^']|'')*'}{ _blank_preserving_newlines($&) }gse;
    return $masked;
}

sub scan_sas_text_for_open_code_macro_control {
    my ($text) = @_;
    my $masked = sanitize_sas_text_for_macro_lint($text);
    my @lines = split /\n/, ($masked // ''), -1;
    my @findings;
    my $macro_depth = 0;

    for my $idx (0 .. $#lines) {
        my $line_no = $idx + 1;
        my $line = $lines[$idx] // '';

        if ($line =~ /^\s*%macro\b/i) {
            $macro_depth++;
            next;
        }

        if ($line =~ /^\s*%mend\b/i) {
            if ($macro_depth > 0) {
                $macro_depth--;
            } else {
                push @findings, {
                    type        => 'open_code_mend',
                    line        => $line_no,
                    message     => "Macro end statement %mend appears outside a %macro/%mend block",
                    context_ref => [ ($line_no - 2) .. ($line_no + 2) ],
                };
            }
            next;
        }

        next if $macro_depth > 0;

        if ($line =~ /^\s*%(goto|return)\b/i) {
            my $stmt = lc($1);
            push @findings, {
                type        => 'open_code_macro_control',
                line        => $line_no,
                message     => "Macro control statement %$stmt appears in open SAS code outside a %macro/%mend block",
                context_ref => [ ($line_no - 2) .. ($line_no + 2) ],
            };
        }
    }

    if ($macro_depth > 0) {
        push @findings, {
            type        => 'unclosed_macro_definition',
            line        => scalar(@lines) || 1,
            message     => "A %macro block appears to be missing its matching %mend",
            context_ref => [ ((scalar(@lines) || 1) - 4) .. (scalar(@lines) || 1) ],
        };
    }

    return {
        lines    => \@lines,
        findings => \@findings,
    };
}

sub line_number_for_offset {
    my ($text, $offset) = @_;
    return 1 unless defined $text && defined $offset && $offset > 0;
    my $prefix = substr($text, 0, $offset);
    my $count = () = ($prefix =~ /\n/g);
    return $count + 1;
}

sub scan_sas_text_for_unbalanced_macro_invocations {
    my ($text) = @_;
    my $masked = sanitize_sas_text_for_macro_lint($text);
    my @findings;
    return \@findings unless defined $masked && length $masked;

    while ($masked =~ /%([A-Za-z_]\w*)\s*\(/g) {
        my $macro_name = $1;
        my $macro_start = $-[0];
        my $scan_pos = pos($masked);
        my $depth = 1;
        my $line_no = line_number_for_offset($masked, $macro_start);
        my $len = length($masked);
        my $closed = 0;
        my $hit_statement_end = 0;

        while ($scan_pos < $len) {
            my $ch = substr($masked, $scan_pos, 1);
            if ($ch eq '(') {
                $depth++;
            } elsif ($ch eq ')') {
                $depth--;
                if ($depth == 0) {
                    $closed = 1;
                    last;
                }
            } elsif ($ch eq ';' && $depth > 0) {
                $hit_statement_end = 1;
                last;
            }
            $scan_pos++;
        }

        next if $closed;
        my $detail = $hit_statement_end
          ? "before the statement semicolon"
          : "before the end of submitted code";
        push @findings, {
            type        => 'unbalanced_macro_invocation',
            line        => $line_no,
            message     => "Macro invocation %$macro_name( is missing a matching ')' $detail; this can leave SAS waiting for more input",
            context_ref => [ ($line_no - 2) .. ($line_no + 2) ],
        };
    }

    return \@findings;
}

sub scan_sas_text_for_unbalanced_constructs {
    my ($text) = @_;
    my @lines = split /\n/, ($text // ''), -1;
    my @findings;
    my ($in_block_comment, $block_start_line) = (0, 0);
    my ($in_single_quote, $single_start_line) = (0, 0);
    my ($in_double_quote, $double_start_line) = (0, 0);
    my $in_statement_comment = 0;

    for my $idx (0 .. $#lines) {
        my $line_no = $idx + 1;
        my $line = $lines[$idx];
        my $i = 0;
        my $len = length($line);
        while ($i < $len) {
            my $ch = substr($line, $i, 1);
            my $next = ($i + 1 < $len) ? substr($line, $i + 1, 1) : '';

            if ($in_statement_comment) {
                if ($ch eq ';') {
                    $in_statement_comment = 0;
                }
                $i++;
                next;
            }

            if ($in_block_comment) {
                if ($ch eq '*' && $next eq '/') {
                    $in_block_comment = 0;
                    $block_start_line = 0;
                    $i += 2;
                    next;
                }
                $i++;
                next;
            }

            if ($in_single_quote) {
                if ($ch eq "'") {
                    if ($next eq "'") {
                        $i += 2;
                        next;
                    }
                    $in_single_quote = 0;
                    $single_start_line = 0;
                }
                $i++;
                next;
            }

            if ($in_double_quote) {
                if ($ch eq '"') {
                    if ($next eq '"') {
                        $i += 2;
                        next;
                    }
                    $in_double_quote = 0;
                    $double_start_line = 0;
                }
                $i++;
                next;
            }

            if ($ch =~ /\s/) {
                $i++;
                next;
            }

            if ($i == 0 || substr($line, 0, $i) =~ /^\s*$/) {
                if ($ch eq '*') {
                    $in_statement_comment = 1;
                    $i++;
                    next;
                }
                if ($ch eq '%' && $next eq '*') {
                    $in_statement_comment = 1;
                    $i += 2;
                    next;
                }
            }

            if ($ch eq '/' && $next eq '*') {
                $in_block_comment = 1;
                $block_start_line = $line_no;
                $i += 2;
                next;
            }
            if ($ch eq '*' && $next eq '/') {
                push @findings, {
                    type        => 'unexpected_comment_close',
                    line        => $line_no,
                    message     => "Unexpected closing block comment '*/'",
                    context_ref => [ ($line_no - 2) .. ($line_no + 2) ],
                };
                $i += 2;
                next;
            }
            if ($ch eq "'") {
                $in_single_quote = 1;
                $single_start_line = $line_no;
                $i++;
                next;
            }
            if ($ch eq '"') {
                $in_double_quote = 1;
                $double_start_line = $line_no;
                $i++;
                next;
            }
            $i++;
        }
    }

    if ($in_block_comment) {
        push @findings, {
            type        => 'unclosed_block_comment',
            line        => $block_start_line || scalar(@lines),
            message     => "Unclosed block comment starting on line " . ($block_start_line || scalar(@lines)),
            context_ref => [ (($block_start_line || scalar(@lines)) - 2) .. scalar(@lines) ],
        };
    }
    if ($in_single_quote) {
        push @findings, {
            type        => 'unclosed_single_quote',
            line        => $single_start_line || scalar(@lines),
            message     => "Unclosed single-quoted string starting on line " . ($single_start_line || scalar(@lines)),
            context_ref => [ (($single_start_line || scalar(@lines)) - 2) .. scalar(@lines) ],
        };
    }
    if ($in_double_quote) {
        push @findings, {
            type        => 'unclosed_double_quote',
            line        => $double_start_line || scalar(@lines),
            message     => "Unclosed double-quoted string starting on line " . ($double_start_line || scalar(@lines)),
            context_ref => [ (($double_start_line || scalar(@lines)) - 2) .. scalar(@lines) ],
        };
    }

    my $macro_scan = scan_sas_text_for_open_code_macro_control($text);
    push @findings, @{ $macro_scan->{findings} || [] };
    push @findings, @{ scan_sas_text_for_unbalanced_macro_invocations($text) };

    return {
        lines    => \@lines,
        findings => \@findings,
    };
}

sub format_sas_preflight_report {
    my (%args) = @_;
    my $display_path = $args{display_path} // '(unknown include target)';
    my $scan = $args{scan} || {};
    my $heading = $args{heading} // '=== Include Preflight ===';
    my $success_message = $args{success_message}
        // 'No obvious unmatched block comments or unterminated quoted strings were detected.';
    my @lines = @{ $scan->{lines} || [] };
    my @findings = @{ $scan->{findings} || [] };
    my @warning_findings = @{ $args{warning_findings} || [] };
    my @report;
    push @report, $heading;
    push @report, "Target: $display_path";
    push @report, "Total lines: " . scalar(@lines);
    if (!@findings && !@warning_findings) {
        push @report, $success_message;
        return join("\n", @report);
    }

    my @context_lines;
    if (@findings) {
        push @report, "Potential compile-blocking findings:";
        for my $finding (@findings) {
            push @report, "- line " . ($finding->{line} // '?') . ": " . ($finding->{message} // 'unknown issue');
            push @context_lines, @{ $finding->{context_ref} || [] };
        }
    }
    if (@warning_findings) {
        push @report, "Warnings:";
        for my $finding (@warning_findings) {
            push @report, "- line " . ($finding->{line} // '?') . ": " . ($finding->{message} // 'unknown issue');
            push @context_lines, @{ $finding->{context_ref} || [] };
        }
    }
    if (@context_lines) {
        my @ranges = collapse_line_ranges(\@context_lines, scalar(@lines));
        push @report, "Context:";
        for my $range (@ranges) {
            my ($start, $end) = @{$range};
            $start = 1 if $start < 1;
            $end = scalar(@lines) if $end > scalar(@lines);
            push @report, "-- lines $start-$end --";
            for my $line_no ($start .. $end) {
                my $text = $lines[$line_no - 1] // '';
                push @report, format_line_number($line_no) . ": " . $text;
            }
        }
    }

    return join("\n", @report);
}

sub scan_sas_text_for_inline_data_step_cards {
    my ($text) = @_;
    my @findings;
    return \@findings unless defined $text && length $text;
    my @lines = split /\r?\n/, $text, -1;
    for my $idx (0 .. $#lines) {
        my $line = $lines[$idx] // '';
        next unless $line =~ /\b(?:datalines4?|cards4?|parmcards4?)\s*;/i;
        next unless $line =~ /\b(?:datalines4?|cards4?|parmcards4?)\s*;\s*\S/i;
        push @findings, {
            type        => 'inline_cards_data',
            line        => $idx + 1,
            message     => "Inline DATALINES/CARDS data was detected after the statement terminator; with --code this often fails unless the data starts on following lines and ends with a standalone semicolon line. Prefer --code '-' with a heredoc or other STDIN input for raw data blocks.",
            context_ref => [ $idx, $idx + 1, $idx + 2 ],
        };
    }
    return \@findings;
}

sub scan_sas_text_for_common_macro_typos {
    my ($text) = @_;
    my @findings;
    return \@findings unless defined $text && length $text;

    my %suggestions = (
        macorparas => 'macroparas',
    );
    my @lines = split /\r?\n/, $text, -1;
    for my $idx (0 .. $#lines) {
        my $line = $lines[$idx];
        while ($line =~ /%([A-Za-z_]\w*)\b/g) {
            my $macro_name = $1;
            my $suggestion = $suggestions{lc $macro_name};
            next unless defined $suggestion;
            push @findings, {
                line        => $idx + 1,
                type        => 'common_macro_typo',
                message     => "Macro %$macro_name is commonly a typo for %$suggestion; use %$suggestion(...) if you want the macro parameter listing helper.",
                context_ref => [ $idx + 1 ],
            };
        }
    }
    return \@findings;
}

sub run_submission_preflight {
    my (%args) = @_;
    my $submitted_code = $args{submitted_code} // '';
    my $display_path = $args{display_path} // '(submitted SAS program)';
    my $scan = scan_sas_text_for_unbalanced_constructs($submitted_code);
    my @warning_findings;
    push @warning_findings, @{ scan_sas_text_for_inline_data_step_cards($submitted_code) };
    push @warning_findings, @{ scan_sas_text_for_common_macro_typos($submitted_code) };
    my $fatal = @{ $scan->{findings} || [] } ? 1 : 0;
    my $report = format_sas_preflight_report(
        heading => '=== Submission Preflight ===',
        display_path => $display_path,
        scan => $scan,
        warning_findings => \@warning_findings,
        success_message => 'No obvious unmatched comments, unterminated quoted strings, or open-code macro-control statements were detected.',
    );

    print "Submission preflight: " .
      ($fatal ? 'possible compile blockers detected' : 'no obvious compile blockers detected') .
      " for $display_path\n";

    return {
        fatal  => $fatal,
        report => $report,
    };
}

sub combine_preflight_reports {
    my (@parts) = @_;
    my @reports;
    my %seen;
    for my $part (@parts) {
        next unless ref($part) eq 'HASH';
        my $report = $part->{report} // '';
        next unless length $report;
        next if $seen{$report}++;
        push @reports, $report;
    }
    return join("\n\n", @reports);
}

sub build_remote_excerpt_code {
    my (%args) = @_;
    my $remote_path = $args{remote_path} // '';
    my $scan = $args{scan} || {};
    my @findings = @{ $scan->{findings} || [] };
    return '' unless length $remote_path && @findings;

    my @context_lines;
    for my $finding (@findings) {
        push @context_lines, @{ $finding->{context_ref} || [] };
    }
    my @ranges = collapse_line_ranges(\@context_lines, scalar(@{ $scan->{lines} || [] }));
    return '' unless @ranges;

    my @conds = map {
        my ($st, $en) = @{$_};
        "(_lineno >= $st and _lineno <= $en)"
    } @ranges;
    my $cond = join(' or ', @conds);
    my $safe_path = $remote_path;
    $safe_path =~ s/"/""/g;
    return join "\n",
        "options source2;",
        "data _null_;",
        "  infile \"$safe_path\" lrecl=32767 truncover end=_eof_;",
        "  input;",
        "  _lineno + 1;",
        "  if $cond then putlog 'SRC ' _lineno z6. ': ' _infile_;",
        "run;",
        "";
}

sub normalize_remote_include_path {
    my ($path, $remote_home_path) = @_;
    return '' unless defined $path && length $path;
    if ($path =~ m{^~/}) {
        return '' unless defined $remote_home_path && length $remote_home_path;
        return $remote_home_path . '/' . substr($path, 2);
    }
    return $path if $path =~ m{^/};
    return '';
}

sub run_include_preflight {
    my (%args) = @_;
    my $submitted_code = $args{submitted_code} // '';
    my $remote_home_path = $args{remote_home_path} // '';
    my $out_dir = $args{output_dir} // getcwd();
    my $standalone_target_debug = exists $ENV{STANDALONE_INCLUDE_TARGET_DEBUG}
        ? $ENV{STANDALONE_INCLUDE_TARGET_DEBUG}
        : 0;
    my $refresh_remote_include_targets = exists $ENV{INCLUDE_PREFLIGHT_REFRESH_REMOTE}
        ? $ENV{INCLUDE_PREFLIGHT_REFRESH_REMOTE}
        : 1;
    my @targets = extract_include_targets($submitted_code);
    my @sections;
    my $fatal = 0;
    my %seen_target;
    my $target_count = scalar(@targets);

    print "Include preflight: found $target_count %include target(s).\n";
    print "Include preflight: standalone include-target debug is " .
      ($standalone_target_debug ? 'enabled' : 'disabled') . ".\n";
    print "Include preflight: remote include refresh is " .
      ($refresh_remote_include_targets ? 'enabled' : 'disabled') . ".\n";

    for my $idx (0 .. $#targets) {
        my $target = $targets[$idx];
        next if $seen_target{$target}++;
        my $step_num = $idx + 1;
        print "Include preflight [$step_num/$target_count]: evaluating target $target\n";
        my $remote_target = normalize_remote_include_path($target, $remote_home_path);
        my $local_source = resolve_local_include_path($target);
        $local_source ||= resolve_local_include_path(basename($target)) if is_remote_include_path($target);
        my @notes;

        if ($local_source && is_remote_include_path($target) && $refresh_remote_include_targets) {
            print "Include preflight [$step_num/$target_count]: refreshing remote include target from local file $local_source\n";
            my $uploaded_remote = run_with_possible_fallback(
                'refresh include target upload',
                sub {
                    my ($active_runner) = @_;
                    return $active_runner->upload($local_source);
                },
            );
            if (defined $uploaded_remote && $uploaded_remote !~ /^PYTHON ERROR:/) {
                push @notes, "Refreshed remote include target from local file: $local_source -> $uploaded_remote";
                $remote_target = $uploaded_remote if !$remote_target;
            } else {
                push @notes, "Tried to refresh remote include target from local file but upload did not confirm success: $local_source";
            }
        } elsif ($local_source && is_remote_include_path($target) && !$refresh_remote_include_targets) {
            print "Include preflight [$step_num/$target_count]: remote include refresh skipped for $target\n";
            push @notes, "Skipped remote include refresh due to INCLUDE_PREFLIGHT_REFRESH_REMOTE=0";
        }

        if ((!$local_source || !-e $local_source) && $remote_target) {
            print "Include preflight [$step_num/$target_count]: downloading remote include target for local analysis: $remote_target\n";
            ensure_output_dir($out_dir);
            my $download_path = File::Spec->catfile($out_dir, 'include_preflight_' . ($idx + 1) . '_' . basename($target));
            my $dl = run_with_possible_fallback(
                'include preflight source download',
                sub {
                    my ($active_runner) = @_;
                    return $active_runner->download($remote_target, $download_path);
                },
            );
            if (defined $dl && $dl !~ /^PYTHON ERROR:/ && -e $download_path) {
                $local_source = $download_path;
                push @notes, "Downloaded remote include target for local preflight analysis: $remote_target";
            } else {
                push @notes, "Could not download remote include target for local preflight analysis: $target";
            }
        }

        if (!$local_source || !-e $local_source) {
            print "Include preflight [$step_num/$target_count]: no local or downloadable copy was available for $target\n";
            push @sections, join("\n",
                "=== Include Preflight ===",
                "Target: $target",
                @notes,
                "Could not access a local copy for preflight analysis.",
            );
            next;
        }

        print "Include preflight [$step_num/$target_count]: scanning local source $local_source\n";
        my $text = slurp_text_file($local_source);
        my $scan = scan_sas_text_for_unbalanced_constructs($text);
        $fatal = 1 if @{ $scan->{findings} || [] };
        my $report = format_sas_preflight_report(
            display_path => $target,
            scan         => $scan,
        );
        if (@notes) {
            $report .= "\n" . join("\n", @notes);
        }

        if ($remote_target && @{ $scan->{findings} || [] }) {
            print "Include preflight [$step_num/$target_count]: local scan found possible compile blockers; requesting remote excerpt from $remote_target\n";
            my $excerpt_code = build_remote_excerpt_code(
                remote_path => $remote_target,
                scan        => $scan,
            );
            if (length $excerpt_code) {
                my $excerpt_result = run_hash_with_possible_fallback(
                    'include preflight remote excerpt',
                    sub {
                        my ($active_runner) = @_;
                        return $active_runner->run_code($excerpt_code);
                    },
                );
                if (ref($excerpt_result) eq 'HASH' && length($excerpt_result->{log} // '')) {
                    $report .= "\n\n=== Remote Source Excerpt ===\n" . ($excerpt_result->{log} // '');
                }
            }
        }

        push @sections, $report;

        if ($standalone_target_debug) {
            print "Include preflight [$step_num/$target_count]: running standalone include-target debug submit for $target\n";
            my $standalone = run_standalone_include_target_debug(
                display_path     => $target,
                local_source     => $local_source,
                remote_home_path => $remote_home_path,
                output_dir       => $out_dir,
                index            => $idx + 1,
            );
            $fatal = 1 if $standalone->{fatal};
            push @sections, ($standalone->{report} // '');
        } else {
            print "Include preflight [$step_num/$target_count]: standalone include-target debug skipped for $target\n";
        }

        print "Include preflight [$step_num/$target_count]: finished target $target\n";
    }

    print "Include preflight: completed evaluation of $target_count target(s).\n";

    return {
        target_count => scalar(@targets),
        fatal        => $fatal,
        report       => join("\n\n", grep { defined $_ && length $_ } @sections),
    };
}

sub build_include_debug_wrapper {
    my (%args) = @_;
    my $sas_code = $args{sas_code} // '';
    my $wrapped_body = $sas_code;
    $wrapped_body =~ s{(%include\b\s+(?:"[^"]+"|'[^']+'))(\s*)(?=\n|$)}{$1;$2}ig;
    my $remote_log_path = $args{remote_log_path} // '/home/include_debug.log';
    my $local_log_path = $args{local_log_path} // File::Spec->catfile(getcwd(), 'include_debug_remote.log');
    my $output_dir = $args{output_dir} // dirname($local_log_path);
    my $remote_label = $remote_log_path;
    $remote_label =~ s/"/""/g;
    my $wrapped = join "\n",
        "filename odaidbg \"$remote_label\";",
        "proc printto log=odaidbg new; run;",
        "options source2 mprint mlogic symbolgen;",
        "/* Auto-injected include-debug wrapper: begin */",
        $wrapped_body,
        "/* Auto-injected include-debug wrapper: end */",
        "proc printto; run;",
        "filename odaidbg clear;",
        "";
    return {
        enabled         => 1,
        remote_log_path => $remote_log_path,
        local_log_path  => $local_log_path,
        output_dir      => $output_dir,
        wrapped_code    => $wrapped,
    };
}

sub summarize_sas_log_text {
    my ($text) = @_;
    return '' unless defined $text && length $text;
    my @lines = split /\n/, $text, -1;
    if (@lines > 220) {
        @lines = (@lines[0 .. 39], '...', @lines[$#lines-179 .. $#lines]);
    }
    return join("\n", @lines);
}

sub sas_log_contains_fatal_error {
    my ($text) = @_;
    return 0 unless defined $text && length $text;
    return 1 if $text =~ /WARNING:\s+Apparent invocation of macro\s+\w+\s+not resolved\./i;
    return 1 if $text =~ /ERROR:\s+Macro\s+\w+\s+not defined/i;
    return 1 if $text =~ /ERROR:\s+The macro\s+\w+\s+was not found/i;
    return 1 if $text =~ /ERROR:\s+The macro\s+\w+\s+will stop executing\./i;
    return 1 if $text =~ /ERROR:\s+A character operand was found in the %EVAL function or %IF condition where a numeric operand is required\./i;
    return 1 if $text =~ /ERROR:\s+/i;
    return 1 if $text =~ /^\s*ERROR\s+\d+-\d+:/mi;
    return 0;
}

sub first_fatal_sas_log_line {
    my ($text) = @_;
    return '' unless defined $text && length $text;
    for my $line (split /\r?\n/, $text) {
        next unless defined $line;
        if ($line =~ /WARNING:\s+Apparent invocation of macro\s+\w+\s+not resolved\./i
            || $line =~ /ERROR:\s+/i
            || $line =~ /^\s*ERROR\s+\d+-\d+:/i) {
            return $line;
        }
    }
    return '';
}

sub run_standalone_include_target_debug {
    my (%args) = @_;
    my $display_path = $args{display_path} // '(unknown include target)';
    my $local_source = $args{local_source} // '';
    my $remote_home_path = $args{remote_home_path} // '';
    my $out_dir = $args{output_dir} // getcwd();
    my $index = $args{index} // 0;

    return {
        fatal  => 0,
        report => "=== Standalone Include Target Debug ===\nTarget: $display_path\nSkipped because no local source was available.",
    } unless $local_source && -e $local_source;

    my $code = slurp_text_file($local_source);
    my $safe_base = basename($local_source);
    $safe_base =~ s/[^A-Za-z0-9_.-]+/_/g;
    my $remote_log_path = ($remote_home_path || '/home') . "/include_target_debug_${index}_${safe_base}.log";
    my $local_log_path = File::Spec->catfile($out_dir, "include_target_debug_${index}_${safe_base}.log");
    print "Standalone include-target debug [$index]: submitting wrapped target $display_path\n";
    my $wrapped = build_include_debug_wrapper(
        sas_code        => $code,
        remote_log_path => $remote_log_path,
        local_log_path  => $local_log_path,
        output_dir      => $out_dir,
    );
    my $result = run_hash_with_possible_fallback(
        "standalone include target debug: $display_path",
        sub {
            my ($active_runner) = @_;
            return $active_runner->run_code($wrapped->{wrapped_code});
        },
    );

    my $error = '';
    my $log = '';
    if (ref($result) eq 'HASH') {
        $error = $result->{error} // '';
        $log = $result->{log} // '';
    } elsif (defined $result) {
        $error = "$result";
    } else {
        $error = 'standalone include target debug returned no result';
    }

    print "Standalone include-target debug [$index]: completed for $display_path";
    print length($error) ? " with error.\n" : ".\n";

    my $fatal = 0;
    $fatal = 1 if length $error;
    $fatal = 1 if $log =~ /ERROR:/i;
    $fatal = 1 if $log =~ /quoted string currently being processed/i;
    $fatal = 1 if $log =~ /unbalanced quotation marks/i;

    my @report = (
        "=== Standalone Include Target Debug ===",
        "Target: $display_path",
        "Local source: $local_source",
        "Remote debug log path: $remote_log_path",
    );
    push @report, "Error: $error" if length $error;
    if (length $log) {
        push @report, "Log excerpt:";
        push @report, summarize_sas_log_text($log);
    } else {
        push @report, "No inline SAS log was returned by the standalone include target debug submit.";
    }

    return {
        fatal  => $fatal,
        report => join("\n", @report),
    };
}

sub auto_download_include_debug_log {
    my ($ctx) = @_;
    return $ctx unless ref($ctx) eq 'HASH' && $ctx->{enabled};
    ensure_output_dir($ctx->{output_dir}) if defined $ctx->{output_dir};
    my $remote_path = $ctx->{remote_log_path} // '';
    my $local_path = $ctx->{local_log_path} // '';
    return $ctx unless length $remote_path && length $local_path;

    my $info = run_hash_with_possible_fallback(
        'auto include-debug log file-info',
        sub {
            my ($active_runner) = @_;
            return $active_runner->fileinfo($remote_path);
        },
    );
    if (!ref($info) || ref($info) ne 'HASH' || !$info->{exists}) {
        $ctx->{downloaded} = 0;
        $ctx->{download_error} = 'remote include-debug log not found';
        return $ctx;
    }

    my $localpath = run_with_possible_fallback(
        'auto include-debug log download',
        sub {
            my ($active_runner) = @_;
            return $active_runner->download($remote_path, $local_path);
        },
    );

    if (defined $localpath && $localpath !~ /^PYTHON ERROR:/ && -s $local_path) {
        $ctx->{downloaded} = 1;
        $ctx->{download_local_path} = $local_path;
        $ctx->{log_text} = slurp_text_file($local_path);
    } else {
        $ctx->{downloaded} = 0;
        $ctx->{download_error} = defined $localpath ? $localpath : 'download failed';
    }

    return $ctx;
}

sub upload_one_file {
    my ($local_path) = @_;
    print "Uploading file '$local_path' to remote SAS ODA...\n";
    if ($persistent && $session_id) {
        print "Using persistent SAS ODA session '$session_id' for upload...\n";
    }
    my $remote_path = run_with_possible_fallback(
        'upload',
        sub {
            my ($active_runner) = @_;
            return $active_runner->upload(
                $local_path,
                {
                    skip_if_same => $skip_upload_if_same,
                },
            );
        },
    );
    if (!defined $remote_path || $remote_path =~ /^PYTHON ERROR:/) {
        die "Upload failed: " . (defined $remote_path ? $remote_path : 'unknown upload error') . "\n";
    }
    print "Remote path for the file is $remote_path\n";
    my $remote_info = run_hash_with_possible_fallback(
        'file-info lookup after upload',
        sub {
            my ($active_runner) = @_;
            return $active_runner->fileinfo($remote_path);
        },
    );
    if (ref($remote_info) eq 'HASH' && ($remote_info->{exists} || defined $remote_info->{size})) {
        my $size_text = defined $remote_info->{size} ? $remote_info->{size} . " bytes" : "unknown size";
        print "Remote size verified: $size_text\n";
        print "Remote created time: $remote_info->{created}\n" if defined $remote_info->{created} && length $remote_info->{created};
        print "Remote modified time: $remote_info->{modified}\n" if defined $remote_info->{modified} && length $remote_info->{modified};
    }
}

sub download_one_file {
    my ($remote_path, $resolved_local_download) = @_;
    print "Downloading file '$remote_path' from remote SAS ODA...\n";
    if ($persistent && $session_id) {
        print "Using persistent SAS ODA session '$session_id' for download...\n";
    }
    my $remote_info = run_hash_with_possible_fallback(
        'file-info lookup before download',
        sub {
            my ($active_runner) = @_;
            return $active_runner->fileinfo($remote_path);
        },
    );
    if (!ref($remote_info) || ref($remote_info) ne 'HASH' || !$remote_info->{exists}) {
        die "Download failed: remote file does not exist in SAS ODA: $remote_path\n";
    }
    my $localpath = run_with_possible_fallback(
        'download',
        sub {
            my ($active_runner) = @_;
            return $active_runner->download($remote_path, $resolved_local_download);
        },
    );
    if (!defined $localpath || $localpath =~ /^PYTHON ERROR:/) {
        die "Download failed: " . (defined $localpath ? $localpath : 'unknown download error') . "\n";
    }
    my $verified_local_path = File::Spec->rel2abs($localpath);
    if (!-e $verified_local_path) {
        die "Download failed: helper reported local path but no file was created: $verified_local_path\n";
    }
    if (defined($remote_info->{size}) && $remote_info->{size} > 0) {
        my $local_size = -s $verified_local_path;
        if (!defined($local_size) || $local_size <= 0) {
            die "Download failed: helper reported success but downloaded file is empty: $verified_local_path\n";
        }
    }
    print "The file is saved as $verified_local_path\n";
}

sub remote_path_for_file_action {
    my ($remote_file, $remote_dir) = @_;
    return $remote_file if defined($remote_file) && $remote_file =~ m{^(?:~/|/)};
    return compose_remote_path_for_match($remote_dir, $remote_file);
}

sub delete_one_file {
    my ($remote_file, $remote_dir) = @_;
    print "Deleting file $remote_file from remote SAS ODA...\n";
    if ($persistent && $session_id) {
        print "Using persistent SAS ODA session '$session_id' for delete...\n";
    }
    my $delete_msg = run_with_possible_fallback(
        'delete',
        sub {
            my ($active_runner) = @_;
            return $active_runner->delete($remote_file, $remote_dir);
        },
    );
    if (defined $delete_msg && $delete_msg =~ /^PYTHON ERROR:/) {
        die "Delete failed: $delete_msg\n";
    }
    my $verify_path = remote_path_for_file_action($remote_file, $remote_dir);
    my $remote_info = run_hash_with_possible_fallback(
        'file-info lookup after delete',
        sub {
            my ($active_runner) = @_;
            return $active_runner->fileinfo($verify_path);
        },
    );
    if (ref($remote_info) eq 'HASH' && $remote_info->{exists}) {
        my $size_text = defined $remote_info->{size} ? $remote_info->{size} . " bytes" : 'unknown size';
        die "Delete failed: remote file still exists after delete attempt: $verify_path ($size_text)\n";
    }
}

sub compose_remote_path_for_match {
    my ($remote_dir, $entry) = @_;
    return $entry if !defined $remote_dir || $remote_dir eq '' || $remote_dir eq '.';
    return $entry if $entry =~ m{^(?:~/|/)};  # already a path-like target
    my $prefix = $remote_dir;
    $prefix =~ s{/+$}{};
    return $prefix . '/' . $entry;
}

#Make the upload file before running any codes, so that the uploaded file can be used in the code if needed.
if(@upload_files){
    for my $upload_path (@upload_files) {
        upload_one_file($upload_path);
    }
}

my $execution_code = $code;
my $execution_file = $file;
my $submitted_display = $code ? $code : ($file // '');
my $include_debug_ctx;
my $submission_preflight;
my $include_preflight;
my $skip_execution_due_to_preflight = 0;
my $preflight_error = '';
my $remote_home_path = '';
my $wrap_file_include_debug = exists $ENV{WRAP_FILE_INCLUDE_DEBUG}
    ? $ENV{WRAP_FILE_INCLUDE_DEBUG}
    : 0;
my $submission_preflight_enabled = exists $ENV{SUBMISSION_PREFLIGHT_ENABLED}
    ? $ENV{SUBMISSION_PREFLIGHT_ENABLED}
    : 1;
my $include_preflight_enabled = exists $ENV{INCLUDE_PREFLIGHT_ENABLED}
    ? $ENV{INCLUDE_PREFLIGHT_ENABLED}
    : 1;
my $saw_explicit_include = 0;

if ($file) {
    my $file_text = slurp_text_file($file);
    $submitted_display = $file;
    if ($submission_preflight_enabled) {
        $submission_preflight = run_submission_preflight(
            submitted_code => $file_text,
            display_path   => $file,
        );
        if ($submission_preflight->{fatal}) {
            $skip_execution_due_to_preflight = 1;
            $preflight_error = "Submission preflight found likely compile-blocking issues in $file; skipped SAS submit";
        }
    } else {
        print "Submission preflight is disabled by SUBMISSION_PREFLIGHT_ENABLED=0; executing $file without submission preflight.\n";
    }

    if (!$skip_execution_due_to_preflight && sas_submission_contains_include($file_text)) {
        $saw_explicit_include = 1;
        $remote_home_path = $runner->get_sas_home_path() unless length $remote_home_path;
        $remote_home_path = '' unless defined $remote_home_path && $remote_home_path !~ /^PYTHON ERROR:/ && $remote_home_path =~ m{^/};
        if ($include_preflight_enabled) {
            print "Detected %include in SAS script. Running include preflight and refreshing matching remote include targets before executing the original SAS file.\n";
            $include_preflight = run_include_preflight(
                submitted_code   => $file_text,
                remote_home_path => $remote_home_path,
                output_dir       => $output_dir,
            );
        } else {
            print "Detected %include in SAS script. Include preflight is disabled by INCLUDE_PREFLIGHT_ENABLED=0; executing the original SAS file without include preflight.\n";
        }
        if ($wrap_file_include_debug) {
            my $base = basename($output_dir);
            $base =~ s/[^A-Za-z0-9_.-]+/_/g;
            my $remote_log_path = ($remote_home_path || '/home') . "/include_debug_${base}.log";
            my $local_log_path = File::Spec->catfile($output_dir, 'include_debug_remote.log');
            $include_debug_ctx = build_include_debug_wrapper(
                sas_code         => $file_text,
                remote_log_path  => $remote_log_path,
                local_log_path   => $local_log_path,
            );
            $execution_code = $include_debug_ctx->{wrapped_code};
            $execution_file = undef;
            print "WRAP_FILE_INCLUDE_DEBUG=$wrap_file_include_debug, so the parent SAS file will also run through the include-debug wrapper with remote log capture: $remote_log_path\n";
        }
    }
} elsif ($code) {
    $submitted_display = $code;
    if ($submission_preflight_enabled) {
        $submission_preflight = run_submission_preflight(
            submitted_code => $code,
            display_path   => '(inline SAS code)',
        );
        if ($submission_preflight->{fatal}) {
            $skip_execution_due_to_preflight = 1;
            $preflight_error = "Submission preflight found likely compile-blocking issues in inline SAS code; skipped SAS submit";
        }
    } else {
        print "Submission preflight is disabled by SUBMISSION_PREFLIGHT_ENABLED=0 for inline SAS code.\n";
    }

    if (!$skip_execution_due_to_preflight && sas_submission_contains_include($code)) {
        $saw_explicit_include = 1;
        my $base = basename($output_dir);
        $base =~ s/[^A-Za-z0-9_.-]+/_/g;
        $remote_home_path = $runner->get_sas_home_path() unless length $remote_home_path;
        $remote_home_path = '' unless defined $remote_home_path && $remote_home_path !~ /^PYTHON ERROR:/ && $remote_home_path =~ m{^/};
        my $remote_log_path = ($remote_home_path || '/home') . "/include_debug_${base}.log";
        my $local_log_path = File::Spec->catfile($output_dir, 'include_debug_remote.log');
        $include_debug_ctx = build_include_debug_wrapper(
            sas_code         => $code,
            remote_log_path  => $remote_log_path,
            local_log_path   => $local_log_path,
        );
        $execution_code = $include_debug_ctx->{wrapped_code};
        print "Detected %include in inline SAS code. Auto-injecting include-debug wrapper and remote log capture: $remote_log_path\n";
        if ($include_preflight_enabled) {
            $include_preflight = run_include_preflight(
                submitted_code   => $code,
                remote_home_path => $remote_home_path,
                output_dir       => $output_dir,
            );
        } else {
            print "Include preflight is disabled by INCLUDE_PREFLIGHT_ENABLED=0 for inline SAS code.\n";
        }
    }
}

if ($saw_explicit_include) {
    if (exists $ENV{SAS_ODA_AUTOLOAD_MACROS} && !$ENV{SAS_ODA_AUTOLOAD_MACROS}) {
        print "Detected explicit %include usage and SAS_ODA_AUTOLOAD_MACROS=0 is already set, so global importallmacros_ue bootstrap remains disabled for this submit.\n";
    } else {
        print "Detected explicit %include usage in the submitted SAS program. Preserving global importallmacros_ue bootstrap so ~/Macros are loaded before later local %include blocks.\n";
    }
}

if (!$skip_execution_due_to_preflight && $include_preflight && $include_preflight->{fatal}) {
    $skip_execution_due_to_preflight = 1;
    $preflight_error = "Include preflight found likely compile-blocking issues in one or more %include targets; skipped actual %include submit";
}

my $result;
my $sas_execution_failed = 0;
my $sas_execution_error = '';
my $submit_text_for_autoload = $execution_file ? slurp_text_file($execution_file) : ($execution_code // '');
my $submit_should_autoload_macros = should_autoload_macros_for_submission($submit_text_for_autoload) ? 1 : 0;

if ($execution_file || ($execution_code && $execution_code !~ /^\s*$/)) {
    ensure_output_dir($output_dir);
    write_status_file(
        $status_file,
        {
            state           => 'starting',
            phase           => 'wrapper_start',
            message         => 'Preparing SAS ODA run',
            complete        => 0,
            success         => 0,
            pid             => $$,
            output_dir      => File::Spec->rel2abs($output_dir),
            output_prefix   => $output_prefix_path,
            target          => ($execution_file || '(inline SAS code)'),
            persistent      => ($persistent ? 1 : 0),
            session_id      => ($session_id // ''),
        }
    );
    print "Live status file: $status_file\n";
    if (!$submit_should_autoload_macros) {
        print "No explicit %include or non-builtin macro usage detected; skipping global importallmacros_ue bootstrap for this submit.\n";
    }
}

##Check whether default SAS macros are loaded successfully;
# my $debug = $runner->run_code(q{
#     %put _user_;  /* lists all macro variables - confirms macros loaded */
#     *%put SYSMACRONAME=&SYSMACRONAME;
#     %put _global_;
#     proc catalog cat=work.sasmacr; contents; run;
# });
# print $debug->{log};

if ($skip_execution_due_to_preflight) {
    my $preflight_reports = combine_preflight_reports($submission_preflight, $include_preflight);
    print $preflight_reports . "\n" if length $preflight_reports;
    $result = {
        error    => $preflight_error,
        log      => '',
        lst      => '',
        dep_logs => $preflight_reports,
        output   => '',
        htmlfilename => '',
    };
    $sas_execution_failed = 1;
    $sas_execution_error = $preflight_error;
} elsif ($execution_file) {
    print "Running SAS script: $execution_file\n";
    write_status_file($status_file, {
        state   => 'running',
        phase   => 'wrapper_submit',
        message => "Submitting SAS script: $execution_file",
    }) if $execution_file;
    {
        local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0 if !$submit_should_autoload_macros && !exists $ENV{SAS_ODA_AUTOLOAD_MACROS};
        $result = run_runner_submit_with_timeout(
            label          => "SAS script $execution_file",
            execution_file => $execution_file,
            runner         => $runner,
            macro_dir      => ($macro_dir || "./"),
            open_html      => (!$no_html),
            persistent     => $persistent,
            session_id     => $session_id,
        );
    }
} elsif ($execution_code) {
    if ($execution_code !~/^\s*$/){
      print "Running SAS code\n";
      write_status_file($status_file, {
          state   => 'running',
          phase   => 'wrapper_submit',
          message => 'Submitting inline SAS code',
      });
      {
          local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0 if !$submit_should_autoload_macros && !exists $ENV{SAS_ODA_AUTOLOAD_MACROS};
          $result = run_runner_submit_with_timeout(
              label          => "inline SAS code",
              execution_code => $execution_code,
              runner         => $runner,
              macro_dir      => ($macro_dir || "./"),
              open_html      => (!$no_html),
              persistent     => $persistent,
              session_id     => $session_id,
          );
      }
   }else{print "\nEmpty SAS codes are supplied\n";}
}else{
    #print "No code or file provided, skipping SAS execution of codes or script.\n";
    #$result = {};
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && $persistent
    && $session_id
    && ref($result) eq 'HASH'
    && $result->{error}
    && is_retryable_transport_error($result->{error})
    && persistent_submit_fallback_allowed()) {
    warn "Warning: persistent-session SAS submit hit a known transport failure; retrying once with a one-shot SAS ODA connection because SAS_ODA_ALLOW_PERSISTENT_SUBMIT_FALLBACK=1.\n";
    my $fallback_runner = fallback_runner();
    if ($execution_file) {
        {
            local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0 if !$submit_should_autoload_macros && !exists $ENV{SAS_ODA_AUTOLOAD_MACROS};
            $result = run_runner_submit_with_timeout(
                label          => "fallback SAS script $execution_file",
                execution_file => $execution_file,
                runner         => $fallback_runner,
                macro_dir      => ($macro_dir || "./"),
                open_html      => (!$no_html),
                persistent     => 0,
                session_id     => undef,
            );
        }
    } else {
        {
            local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0 if !$submit_should_autoload_macros && !exists $ENV{SAS_ODA_AUTOLOAD_MACROS};
            $result = run_runner_submit_with_timeout(
                label          => "fallback inline SAS code",
                execution_code => $execution_code,
                runner         => $fallback_runner,
                macro_dir      => ($macro_dir || "./"),
                open_html      => (!$no_html),
                persistent     => 0,
                session_id     => undef,
            );
        }
    }
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && $persistent
    && $session_id
    && ref($result) eq 'HASH'
    && $result->{error}
    && is_retryable_transport_error($result->{error})
    && !persistent_submit_fallback_allowed()) {
    my $notice = persistent_submit_fallback_notice();
    $result->{error} .= "\n$notice" if $result->{error} !~ /\Q$notice\E/;
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && ref($result) eq 'HASH'
    && !length($result->{error} // '')
    && !has_visible_content($result->{htmlfilename})
    && !has_visible_content($result->{log})
    && !has_visible_content($result->{lst})) {
    $sas_execution_failed = 1;
    $sas_execution_error = 'SAS submit returned an empty result without HTML, log, or listing output';
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && ref($result) eq 'HASH'
    && defined($result->{error})
    && length($result->{error})) {
    $sas_execution_failed = 1;
    $sas_execution_error = $result->{error};
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && ref($result) eq 'HASH'
    && !length($result->{error} // '')
    && sas_log_contains_fatal_error($result->{log} // '')) {
    $sas_execution_failed = 1;
    my $first_line = first_fatal_sas_log_line($result->{log} // '');
    $sas_execution_error = 'SAS log contains fatal errors';
    $sas_execution_error .= ": $first_line" if length $first_line;
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && $persistent
    && $session_id
    && ref($result) eq 'HASH'
    && !$result->{error}
    && !has_visible_content($result->{htmlfilename})
    && !has_visible_content($result->{log})
    && !has_visible_content($result->{lst})
    && persistent_submit_fallback_allowed()) {
    warn "Warning: persistent-session SAS submit returned an empty result; retrying once with a one-shot SAS ODA connection because SAS_ODA_ALLOW_PERSISTENT_SUBMIT_FALLBACK=1.\n";
    my $fallback_runner = fallback_runner();
    if ($execution_file) {
        {
            local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0 if !$submit_should_autoload_macros && !exists $ENV{SAS_ODA_AUTOLOAD_MACROS};
            $result = run_runner_submit_with_timeout(
                label          => "fallback SAS script $execution_file",
                execution_file => $execution_file,
                runner         => $fallback_runner,
                macro_dir      => ($macro_dir || "./"),
                open_html      => (!$no_html),
                persistent     => 0,
                session_id     => undef,
            );
        }
    } else {
        {
            local $ENV{SAS_ODA_AUTOLOAD_MACROS} = 0 if !$submit_should_autoload_macros && !exists $ENV{SAS_ODA_AUTOLOAD_MACROS};
            $result = run_runner_submit_with_timeout(
                label          => "fallback inline SAS code",
                execution_code => $execution_code,
                runner         => $fallback_runner,
                macro_dir      => ($macro_dir || "./"),
                open_html      => (!$no_html),
                persistent     => 0,
                session_id     => undef,
            );
        }
    }
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && $persistent
    && $session_id
    && ref($result) eq 'HASH'
    && !$result->{error}
    && !has_visible_content($result->{htmlfilename})
    && !has_visible_content($result->{log})
    && !has_visible_content($result->{lst})
    && !persistent_submit_fallback_allowed()) {
    $result->{error} = "Persistent-session SAS submit returned no HTML, log, or listing output.\n"
      . persistent_submit_fallback_notice();
}

my $combined_preflight_report = combine_preflight_reports($submission_preflight, $include_preflight);
if (ref($result) eq 'HASH' && length($combined_preflight_report // '')) {
    if (($result->{dep_logs} // '') !~ /\Q$combined_preflight_report\E/s) {
        $result->{dep_logs} = length($result->{dep_logs} // '')
          ? ($result->{dep_logs} . "\n\n" . $combined_preflight_report)
          : $combined_preflight_report;
    }
}

if ($include_debug_ctx && ref($result) eq 'HASH') {
    $include_debug_ctx = auto_download_include_debug_log($include_debug_ctx);
    my $note = "Auto include-debug remote SAS log: " . ($include_debug_ctx->{remote_log_path} // '(unknown)');
    if ($include_debug_ctx->{downloaded}) {
        $note .= "\nDownloaded include-debug log to: " . $include_debug_ctx->{download_local_path};
        if (defined $include_debug_ctx->{log_text} && length $include_debug_ctx->{log_text}) {
            $note .= "\n\n=== Downloaded Include-Debug SAS Log ===\n" . $include_debug_ctx->{log_text};
        }
    } else {
        $note .= "\nInclude-debug log download did not produce a local file";
        $note .= ": " . $include_debug_ctx->{download_error} if defined $include_debug_ctx->{download_error};
    }
    $result->{dep_logs} = length($result->{dep_logs} // '')
      ? ($result->{dep_logs} . "\n\n" . $note)
      : $note;

    if (!$sas_execution_failed
        && !($include_debug_ctx->{downloaded})
        && !has_visible_content($result->{log})
        && !has_visible_content($result->{lst})
        && !has_visible_content($result->{htmlfilename})) {
        $sas_execution_failed = 1;
        $sas_execution_error = "Include-debug submission produced no SAS log and no downloadable remote PRINTTO log (" .
          ($include_debug_ctx->{remote_log_path} // 'unknown_remote_log') . ")";
    }
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && ref($result) eq 'HASH'
    && $ENV{SAS_ODA_DEBUG_RESULT_SUMMARY}) {
    my $log_len = defined($result->{log}) ? length($result->{log}) : -1;
    my $lst_len = defined($result->{lst}) ? length($result->{lst}) : -1;
    my $html_len = defined($result->{htmlfilename}) ? length($result->{htmlfilename}) : -1;
    my $dep_len = defined($result->{dep_logs}) ? length($result->{dep_logs}) : -1;
    warn "DEBUG: submit result summary log_len=$log_len lst_len=$lst_len htmlfilename_len=$html_len dep_logs_len=$dep_len error=" .
         (defined($result->{error}) ? $result->{error} : '') . "\n";
}

if (($execution_file || ($execution_code && $execution_code !~ /^\s*$/))
    && ref($result) eq 'HASH'
    && defined($result->{dep_logs})
    && length($result->{dep_logs})) {
    my @auto_upload_lines = grep {
        /Uploaded %include:/ || /Detected macro:/ || /Detected .* dependency\. Uploaded:/
    } split /\r?\n/, ($result->{dep_logs} // '');
    if (@auto_upload_lines) {
        print "WARNING: Internal SAS dependency parsing auto-uploaded local file(s) before submit.\n";
        print "WARNING: This can happen for %include targets, local macro files, or file paths detected in SAS statements.\n";
        print "WARNING: Auto-upload summary:\n";
        print join("\n", map { "  - $_" } @auto_upload_lines), "\n";
    }
}

#Put the download part after running the code, so that users can specify the dataset to be downloaded in the code if needed. 
#For example, users can create a dataset in the code and then specify that dataset to be downloaded.
if (@download_files) {
    for my $i (0 .. $#download_files) {
        my $resolved_local_download = resolve_download_local_path($i, $download_files[$i]);
        download_one_file($download_files[$i], $resolved_local_download);
    }
}

if (@delete_files || @delete_file_rgxs) {
    my @all_delete_targets = @delete_files;
    if (@delete_file_rgxs) {
        print "Resolving remote delete regex matches in $delete_dir...\n";
        my $files_ref = run_array_with_possible_fallback(
            'remote dir listing for delete regex',
            sub {
                my ($active_runner) = @_;
                return $active_runner->filesindir($delete_dir);
            },
        );
        if (!ref($files_ref) || ref($files_ref) ne 'ARRAY') {
            my $msg = defined $files_ref ? $files_ref : 'unknown dir listing error';
            die "Remote dir listing failed for delete regex resolution: $msg\n";
        }
        my %selected = map { $_ => 1 } @all_delete_targets;
        for my $regex_text (@delete_file_rgxs) {
            my $regex = eval { qr/$regex_text/ };
            die "Invalid delete regex '$regex_text': $@\n" if $@;
            my @matched_entries;
            my @matched_display;
            for my $entry (@{$files_ref}) {
                next unless defined $entry;
                my $full_path = compose_remote_path_for_match($delete_dir, $entry);
                next unless ($entry =~ $regex || $full_path =~ $regex);
                push @matched_entries, $entry;
                push @matched_display, $full_path;
            }
            print "Delete regex '$regex_text' matched: " . (@matched_display ? join(', ', @matched_display) : '(none)') . "\n";
            $selected{$_} = 1 for @matched_entries;
        }
        @all_delete_targets = sort keys %selected;
    }
    for my $target (@all_delete_targets) {
        delete_one_file($target, $delete_dir);
    }
}

if ($dir4listing){
  print "Listing files in the remote SAS ODA dir: $dir4listing...\n";
  if ($persistent && $session_id) {
    print "Using persistent SAS ODA session '$session_id' for remote dir listing...\n";
  }
  my $files_ref = run_array_with_possible_fallback(
      'remote dir listing',
      sub {
          my ($active_runner) = @_;
          return $active_runner->filesindir($dir4listing);
      },
  );
  if (!ref($files_ref) || ref($files_ref) ne 'ARRAY') {
    my $msg = defined $files_ref ? $files_ref : 'unknown dir listing error';
    die "Remote dir listing failed: $msg\n";
  }
  #print Dumper($files_ref);
  print "Files in the directory: $dir4listing\n";
  print join("\n",@{$files_ref}),"\n";
}

if (@file_infos) {
  for my $file_info (@file_infos) {
    print "Checking remote file info for $file_info...\n";
    if ($persistent && $session_id) {
      print "Using persistent SAS ODA session '$session_id' for remote file info...\n";
    }
    my $info = run_hash_with_possible_fallback(
        'remote file-info lookup',
        sub {
            my ($active_runner) = @_;
            return $active_runner->fileinfo($file_info);
        },
    );
    if (!ref($info) || ref($info) ne 'HASH') {
      my $msg = defined $info ? $info : 'unknown file info error';
      die "Remote file info failed: $msg\n";
    }
    print "REMOTE_PATH\t" . ($info->{path} // $file_info) . "\n";
    print "EXISTS\t" . (($info->{exists} ? 1 : 0)) . "\n";
    print "SIZE\t" . (defined $info->{size} ? $info->{size} : '') . "\n";
    print "CREATED\t" . (defined $info->{created} ? $info->{created} : '') . "\n";
    print "MODIFIED\t" . (defined $info->{modified} ? $info->{modified} : '') . "\n";
    print "CREATED_EPOCH\t" . (defined $info->{created_epoch} ? $info->{created_epoch} : '') . "\n";
    print "MODIFIED_EPOCH\t" . (defined $info->{modified_epoch} ? $info->{modified_epoch} : '') . "\n";
  }
}

# Save log file; no need anymore!
# my $log_file = "$output_prefix_path.log";
# if ($result->{log}){
#   open my $log_fh, '>', $log_file or die "Cannot open $log_file: $!\n" ;
#   print $log_fh $result->{log};
#   close $log_fh;
#   #print "SAS Log for debugging saved to: $log_file\n";
# }

# Save HTML name and other info to a text file for reference, since the HTML file will be deleted after the session ends and the original path will no longer be valid. This way, users can still access the HTML output after the session ends by referring to this text file.
if (!$no_html and (($execution_code && $execution_code!~/^\s*$/) || $execution_file)) {
    ensure_output_dir($output_dir);
    #Need to move the temporary HTML file to the output directory and save the new path to a text file for reference, since the HTML file will be deleted after the session ends and the original path will no longer be valid. This way, users can still access the HTML output after the session ends by referring to this text file.
    my $htmlfilename = $result->{htmlfilename} // '';
    my $html_basename = $htmlfilename ? basename($htmlfilename) : '';
    my $final_html_path = ($html_basename ? "$output_dir/$html_basename" : '');
    if ($htmlfilename && -e $htmlfilename && $final_html_path) {
        move($htmlfilename, $final_html_path)
          or warn "WARNING: Could not move HTML artifact from $htmlfilename to $final_html_path: $!\n";
    }
    my $allow_auto_open = (!defined($ENV{OPEN_RESULT}) || $ENV{OPEN_RESULT} ne '0') ? 1 : 0;
    auto_open_local_file($final_html_path) if ($allow_auto_open && $final_html_path && -f $final_html_path);
    my $html_file = "$output_prefix_path.html.info.txt";
    my $final_status = read_status_file($status_file);
    my $final_status_summary = summarize_status_hash($final_status);
    open my $html_fh, '>:encoding(UTF-8)', $html_file or die "Cannot open $html_file: $!\n";
    print $html_fh "\n=== Submitted SAS Codes or file ===\n";
    print $html_fh $submitted_display, "\n\n";
    print $html_fh "\n=== Output Directory ===\n$output_dir\n\n";
    print $html_fh "=== Dependency Logs ===\n" . ($result->{dep_logs} || "None") . "\n\n";
    print $html_fh "=== Status Snapshot ===\n" . ($final_status_summary || "None") . "\n\n";
    if ($sas_execution_failed) {
        print $html_fh "=== Error ===\n" . $sas_execution_error . "\n\n";
    }
    print $html_fh "=== SAS Log ===\n" . ($result->{log} // '') . "\n\n";
    my $output_summary = $final_html_path
      ? "HTML output saved to: $final_html_path"
      : ($result->{lst} // "No output");
    print $html_fh "=== Output ===\n" . $output_summary . "\n";
    close $html_fh;
    if ($sas_execution_failed) {
        print "SAS log for debug saved to: $html_file\n";
        print "ERROR: $sas_execution_error\n";
    } elsif ($final_html_path) {
        print "HTML output saved to: $final_html_path\n";
        print "SAS log for debug saved to: $html_file\n";
        print "\nSAS job is completed!\n\nif using AI agent gemini CLI, please press the keyboard 'ESCAPE' key to exit and type 'Check results' !\n";
    } else {
        print "SAS log for debug saved to: $html_file\n";
        print "\nSAS job finished without a downloadable HTML artifact. Check the SAS log above for connection or rendering failures.\n";
    }

}

if ($sas_execution_failed) {
    write_status_file($status_file, {
        state    => 'failed',
        phase    => 'wrapper_finish',
        message  => $sas_execution_error,
        complete => 1,
        success  => 0,
    }) if ($execution_file || ($execution_code && $execution_code !~ /^\s*$/));
    cleanup_empty_output_dir_if_created($output_dir);
    die "ERROR: $sas_execution_error\n";
}

# else{
#    print "\n=== Output Directory ===\n$output_dir\n\n";
#    print "=== Dependency Logs ===\n" . ($result->{dep_logs} || "None") . "\n\n" if $result->{dep_logs};
#    print "=== SAS Log ===\n" . $result->{log} . "\n\n" if $result->{log};
#    print "=== Output ===\n" . ("HTML output saved to: $output_dir/" . $result->{htmlfilename} || $result->{lst} || "No output") . "\n" 
#    if ($result->{htmlfilename} || $result->{lst});
# }

if ($session_id && $persistent) {
    print "\nSession ID: $session_id (reusable for next runs)\n";
}


if (ref($result) eq 'HASH' && $result->{error}) {
    write_status_file($status_file, {
        state    => 'failed',
        phase    => 'wrapper_finish',
        message  => $result->{error},
        complete => 1,
        success  => 0,
    }) if ($execution_file || ($execution_code && $execution_code !~ /^\s*$/));
    cleanup_empty_output_dir_if_created($output_dir);
    print "ERROR: " . $result->{error} . "\n";
    exit 1;
}

if ($execution_file || ($execution_code && $execution_code !~ /^\s*$/)) {
    my $final_msg = has_visible_content($result->{htmlfilename})
      ? 'SAS job completed and produced an HTML artifact'
      : 'SAS job completed without a downloadable HTML artifact';
    write_status_file($status_file, {
        state        => 'completed',
        phase        => 'wrapper_finish',
        message      => $final_msg,
        complete     => 1,
        success      => 1,
        htmlfilename => ($result->{htmlfilename} // ''),
    });
}

cleanup_empty_output_dir_if_created($output_dir);
