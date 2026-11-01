#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../MCPDeps";
use Cwd qw(abs_path);
use Digest::SHA qw(sha256_hex);
use Encode qw(decode encode FB_DEFAULT);
use File::Find qw(find);
use File::Spec;
use JSON::PP qw(encode_json);
use SAS_Source_Analysis;

my ($root,$output)=@ARGV;
die "Usage: $0 COVID19_GWAS_Analyzer_ROOT [OUTPUT_JSON]\n" unless defined $root && -d $root;
$root=abs_path($root);
$output//=File::Spec->catfile($Bin,'..','tests','covid19_gwas_validation_corpus.json');

sub slurp {
    my ($path)=@_;
    open my $fh,'<:raw',$path or die "Cannot read $path: $!\n";
    local $/;
    return decode('UTF-8',<$fh>,FB_DEFAULT);
}

my @files;
find({no_chdir=>1,wanted=>sub {push @files,$File::Find::name if -f $_ && /[.]sas$/i}},$root);
@files=sort @files;
my (@definitions,@includes,@prx,@demos);
my %macro_seen;
for my $path (@files) {
    my $source=slurp($path);
    (my $relative=$path)=~s/^\Q$root\E\///;
    my @lines=split /(?<=\n)/,$source,-1;
    for my $index (0..$#lines) {
        my $line=$lines[$index];
        if ($line=~/^\s*%macro\s+([A-Za-z_][A-Za-z0-9_]*)/i) {
            my $name=$1;
            push @definitions,{name=>$name,path=>$relative,line=>$index+1,evidence=>$line}
              unless $macro_seen{lc $name}++;
        }
        if ($line=~/%include\b/i) {
            push @includes,{
                path=>$relative,
                line=>$index+1,
                source=>$line,
                targets=>SAS_Source_Analysis::include_targets($line),
            };
        }
        if ($line!~/^\s*\/\*/ && $line=~/prx(?:match|change)\s*\(\s*(?:s)?\/.*\*\//i) {
            my $analysis=SAS_Source_Analysis::analyze_source($line);
            my $has_close=grep {$_->{type} eq 'unexpected_comment_close'} @{$analysis->{findings}};
            push @prx,{path=>$relative,line=>$index+1,source=>$line} unless $has_close;
        }
    }
    if ($relative!~m{^Macros/}) {
        my $analysis=SAS_Source_Analysis::analyze_source($source);
        my @types=map {$_->{type}} @{$analysis->{findings}};
        my $view=SAS_Source_Analysis::macro_dependency_view($source);
        my @macro_tokens=$view=~/%([A-Za-z_][A-Za-z0-9_]*)/g;
        push @demos,{
            path=>$relative,
            sha256=>sha256_hex(encode('UTF-8',$source)),
            source=>$source,
            finding_types=>\@types,
            targets=>SAS_Source_Analysis::include_targets($source),
            macro_token_count=>scalar @macro_tokens,
        };
    }
}

die "Need at least 200 unique macro definitions; found ".scalar(@definitions)."\n" if @definitions<200;
die "Need at least 86 include sites; found ".scalar(@includes)."\n" if @includes<86;
die "Expected seven clean unquoted PRX boundary cases; found ".scalar(@prx)."\n" unless @prx==7;
die "Expected seven top-level demo programs; found ".scalar(@demos)."\n" unless @demos==7;

@definitions=@definitions[0..199];
@includes=@includes[0..85];
my @tasks;
for my $definition (@definitions) {
    push @tasks,{kind=>'declaration',%$definition,
        source=>"%macro $definition->{name}();\n%mend $definition->{name};\n"};
}
for my $definition (@definitions) {
    push @tasks,{kind=>'invocation',name=>$definition->{name},path=>$definition->{path},
        line=>$definition->{line},source=>"%$definition->{name}();\n"};
}
push @tasks,map {{kind=>'include',%$_}} @includes;
push @tasks,map {{kind=>'prx_boundary',%$_}} @prx;
push @tasks,map {{kind=>'demo',%$_}} @demos;
die "Internal corpus error: expected 500 tasks, generated ".scalar(@tasks)."\n" unless @tasks==500;

my $commit=`git -C "$root" rev-parse HEAD`;
chomp $commit;
my $manifest={
    source_repository=>'https://github.com/chengzhongshan/COVID19_GWAS_Analyzer',
    source_commit=>$commit,
    generated_task_count=>scalar @tasks,
    categories=>{declaration=>200,invocation=>200,include=>86,prx_boundary=>7,demo=>7},
    tasks=>\@tasks,
};
open my $out,'>:encoding(UTF-8)',$output or die "Cannot write $output: $!\n";
print {$out} JSON::PP->new->canonical->pretty->encode($manifest);
close $out or die "Cannot close $output: $!\n";
print "Wrote 500 COVID19_GWAS_Analyzer validation tasks to $output\n";
