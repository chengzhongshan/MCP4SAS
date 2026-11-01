#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use Digest::SHA qw(sha256_hex);
use Encode qw(encode);
use JSON::PP qw(decode_json);
use Test::More tests => 500;
use SAS_Source_Analysis;

my $manifest_path="$Bin/covid19_gwas_validation_corpus.json";
open my $fh,'<:raw',$manifest_path or die "Cannot read $manifest_path: $!\n";
local $/;
my $manifest=decode_json(<$fh>);
close $fh;
die "Expected a 500-task corpus manifest\n"
  unless $manifest->{generated_task_count}==500 && @{$manifest->{tasks}}==500;

my $number=0;
for my $task (@{$manifest->{tasks}}) {
    $number++;
    my $id=sprintf 'C%03d',$number;
    my $where=defined $task->{line} ? "$task->{path}:$task->{line}" : $task->{path};
    if ($task->{kind} eq 'declaration') {
        my $analysis=SAS_Source_Analysis::analyze_source($task->{source});
        my $view=SAS_Source_Analysis::macro_dependency_view($task->{source});
        ok(!@{$analysis->{findings}} && $view=~/%macro\s+\Q$task->{name}\E\b/i,
            "$id declaration remains executable source [$where]");
    } elsif ($task->{kind} eq 'invocation') {
        my $view=SAS_Source_Analysis::macro_dependency_view($task->{source});
        ok($view=~/%\Q$task->{name}\E\b/i && !@{SAS_Source_Analysis::include_targets($task->{source})},
            "$id invocation remains a non-include dependency [$where]");
    } elsif ($task->{kind} eq 'include') {
        is_deeply(SAS_Source_Analysis::include_targets($task->{source}),$task->{targets},
            "$id include extraction matches source snapshot [$where]");
    } elsif ($task->{kind} eq 'prx_boundary') {
        my $analysis=SAS_Source_Analysis::analyze_source($task->{source});
        my @close=grep {$_->{type} eq 'unexpected_comment_close'} @{$analysis->{findings}};
        is(scalar @close,0,"$id PRX quantifier boundary is not a comment close [$where]");
    } elsif ($task->{kind} eq 'demo') {
        my $analysis=SAS_Source_Analysis::analyze_source($task->{source});
        my $view=SAS_Source_Analysis::macro_dependency_view($task->{source});
        my @tokens=$view=~/%([A-Za-z_][A-Za-z0-9_]*)/g;
        is_deeply(
            {
                sha256=>sha256_hex(encode('UTF-8',$task->{source})),
                finding_types=>[map {$_->{type}} @{$analysis->{findings}}],
                targets=>SAS_Source_Analysis::include_targets($task->{source}),
                macro_token_count=>scalar @tokens,
            },
            {
                sha256=>$task->{sha256},
                finding_types=>$task->{finding_types},
                targets=>$task->{targets},
                macro_token_count=>$task->{macro_token_count},
            },
            "$id complete demo analysis remains stable [$task->{path}]",
        );
    } else {
        fail("$id unknown task kind $task->{kind}");
    }
}
