package SAS_Local_Home;
use strict;
use warnings;
use SAS_Source_Analysis;
use File::Spec;
use Digest::SHA qw(sha256_hex);

# A persistent SAS session keeps one HOME even when each CLI run writes its
# results into a new directory. Explicit --dir4local_sas_home/ENV still wins.
sub default_home {
    my (%args) = @_;
    return $args{output_dir} unless $args{persistent} && length($args{session_id} // '');
    my $session = $args{session_id};
    my $slug = substr($session, 0, 24);
    $slug =~ s/[^A-Za-z0-9_-]/_/g;
    my $key = sha256_hex(join("\0", map { $_ // '' }
        ($args{profile}, $args{cfgfile}, $session)));
    return File::Spec->catdir('local', 'sas-home', $slug . '-' . substr($key, 0, 12));
}

sub python_setup {
    return <<'PY';

def configure_local_templates(sess):
    import re
    cfg = getattr(getattr(sess, '_io', None), 'sascfg', None)
    if getattr(cfg, 'iomhost', None) or getattr(cfg, 'ssh', None):
        return
    if getattr(sess, '_pipeline_local_templates_ready', False):
        return
    # SASUSER may be locked by another SAS instance or live in OneDrive.
    # Keep existing read paths, but write new GTL/style templates into WORK.
    result = sess.submit('ods path (prepend) work.templat(update);', results='text')
    log = str((result or {}).get('LOG', '') or '')
    if re.search(r'^\s*ERROR(?:\s+\d+[-:]|:)', log, re.M):
        raise RuntimeError('Cannot configure local SAS template store:\n' + log)
    sess._pipeline_local_templates_ready = True

def configure_local_home(sess, home):
    import re
    home = str(home or '').replace('\\', '/')
    if not home or getattr(sess, '_pipeline_local_home', '') == home:
        return
    cfg = getattr(getattr(sess, '_io', None), 'sascfg', None)
    if getattr(cfg, 'iomhost', None) or getattr(cfg, 'ssh', None):
        raise ValueError('--dir4local_sas_home requires a local SAS connection')
    if not os.path.isabs(home) or not os.path.isdir(home):
        raise ValueError('Local SAS home must be an existing absolute directory: ' + home)
    literal = "'" + home.replace("'", "''") + "'"
    setup = ('filename HOME ' + literal + '; options set=HOME ' + literal + ';\n'
             'data _null_; call symputx("_USERHOME",' + literal + ',"G"); '
             'call symputx("PIPELINE_SAS_HOME",' + literal + ',"G"); run;')
    # This setup produces no table. Avoid a complete ODS HTML round trip.
    result = sess.submit(setup, results='text')
    log = str((result or {}).get('LOG', '') or '')
    if re.search(r'^\s*ERROR(?:\s+\d+[-:]|:)', log, re.M):
        raise RuntimeError('Cannot configure local SAS home:\n' + log)
    sess._pipeline_local_home = home

PY
}

# Expand quoted SAS path literals only, preserving comments, inline data and
# macro-quoted text. Dynamic paths can use &PIPELINE_SAS_HOME instead.
sub expand_code_paths {
    my ($code, $home) = @_;
    return $code unless defined($home) && length($home);
    my $analysis = SAS_Source_Analysis::analyze_source($code);
    my @spans = sort {$b->{start} <=> $a->{start}}
      (@{$analysis->{single_quotes}}, @{$analysis->{double_quotes}});
    for my $span (@spans) {
        my $literal = substr($code, $span->{start}, $span->{end}-$span->{start});
        my $quote = substr($literal, 0, 1);
        my $body = substr($literal, 1, length($literal)-2);
        next unless $body =~ m{\A~(?:[/\\]|\z)};
        my $prefix = $home;
        $prefix =~ s/\Q$quote\E/$quote$quote/g;
        # Double-quoted paths must not turn & or % in a directory name into
        # macro references. Use the preconfigured macro variable for the root.
        $prefix = '%superq(PIPELINE_SAS_HOME)' if $quote eq '"';
        $body =~ s{\A~}{$prefix};
        substr($code, $span->{start}, $span->{end}-$span->{start}, $quote.$body.$quote);
    }
    return $code;
}

1;
