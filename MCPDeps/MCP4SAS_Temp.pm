package MCP4SAS_Temp;
use strict;
use warnings;
use Cwd qw(abs_path getcwd);
use File::Spec;
use File::Basename qw(basename dirname);
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use JSON::PP qw(encode_json decode_json);

my ($owned_dir, $owner_pid, $owned_root, $keep);

sub initialize {
    my (%opts) = @_;
    my $provided = $ENV{MCP4SAS_WORKER_TEMP_DIR} // '';
    return abs_path($provided) if length($provided) && -d $provided;
    return $owned_dir if defined $owned_dir;
    $owned_root = abs_path(getcwd());
    $owner_pid = $$;
    $keep = $opts{keep} ? 1 : 0;
    my $session_temp = File::Spec->tmpdir();
    $owned_dir = tempdir('.mcp4sas_work_XXXXXX', DIR => $owned_root, CLEANUP => 0);
    open my $fh, '>', "$owned_dir/.mcp4sas-owner.json" or die "Cannot mark scratch: $!";
    print {$fh} encode_json({pid => $$, root => $owned_root, created => time});
    close $fh or die $!;
    $ENV{MCP4SAS_WORKER_TEMP_DIR} = $owned_dir;
    $ENV{MCP4SAS_SESSION_TEMP_DIR} = $session_temp;
    $ENV{TMPDIR} = $owned_dir;
    print STDERR "MCP4SAS intermediate directory: $owned_dir\n";
    return $owned_dir;
}

sub inspect_owned {
    my ($path, $root) = @_;
    $root = abs_path($root) || return;
    return if -l $path;
    my $resolved = abs_path($path) || return;
    return unless dirname($resolved) eq $root
        && basename($resolved) =~ /^\.mcp4sas_work_[A-Za-z0-9_]+$/;
    my $marker = "$resolved/.mcp4sas-owner.json";
    return if -l $marker;
    open my $fh, '<', $marker or return;
    my $info = eval { local $/; decode_json(<$fh>) };
    close $fh;
    return unless ref($info) eq 'HASH' && ($info->{root} // '') eq $root
        && ($info->{pid} // '') =~ /^\d+$/ && ($info->{created} // '') =~ /^\d+$/;
    return ($resolved, $info);
}

sub remove_owned {
    my ($path, $root) = @_;
    my ($resolved) = inspect_owned($path, $root);
    die "Cannot verify owned scratch directory: $path\n" unless $resolved;
    my $errors;
    remove_tree($resolved, {error => \$errors});
    die "Could not remove scratch directory: $resolved\n" if ($errors && @$errors) || -e $resolved;
}

sub cleanup {
    return unless defined($owned_dir) && defined($owner_pid) && $$ == $owner_pid;
    if ($keep) {
        print STDERR "Retained MCP4SAS intermediates: $owned_dir\n";
        return;
    }
    eval { remove_owned($owned_dir, $owned_root); 1 }
        or warn "MCP4SAS scratch cleanup: $@";
}

sub terminate_tree {
    my ($pid) = @_;
    return unless defined($pid) && $pid =~ /^\d+$/ && $pid > 0 && $pid != $$;
    my (%parent, %native);
    my @command = $^O eq 'cygwin' ? ('ps', '-l') : ('ps', '-eo', 'pid=,ppid=');
    if ($^O ne 'MSWin32' && open(my $ps, '-|', @command)) {
        while (my $line = <$ps>) {
            if ($^O eq 'cygwin' && $line =~ /^\s*(\d+)\s+(\d+)\s+\d+\s+(\d+)\s/) {
                $parent{$1} = $2; $native{$1} = $3;
            } elsif ($^O ne 'cygwin' && $line =~ /^\s*(\d+)\s+(\d+)\s*$/) {
                $parent{$1} = $2;
            }
        }
        close $ps;
    }
    my @tree = ($pid);
    my %seen = ($pid => 1);
    for (my $i = 0; $i < @tree; ++$i) {
        push @tree, grep { !$seen{$_}++ && $parent{$_} == $tree[$i] }
            grep { $parent{$_} == $tree[$i] } keys %parent;
    }
    # Translate before terminating the parent; Windows uses a different PID namespace.
    my $windows_pid = $^O eq 'MSWin32' ? $pid : $native{$pid};
    if (($^O eq 'cygwin' || $^O eq 'MSWin32') && $windows_pid) {
        local *STDOUT; local *STDERR;
        open STDOUT, '>', File::Spec->devnull() or die $!;
        open STDERR, '>', File::Spec->devnull() or die $!;
        system('taskkill.exe', '/PID', $windows_pid, '/T', '/F');
    }
    kill 'TERM', reverse @tree;
    select undef, undef, undef, 0.5;
    kill 'KILL', reverse @tree;
}
END { cleanup() }
1;
