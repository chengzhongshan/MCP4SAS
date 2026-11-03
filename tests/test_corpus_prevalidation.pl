#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/../tools/lib"; use Library_Evaluation_Corpus;
use File::Temp qw(tempdir); use File::Path qw(make_path); use JSON::PP qw(decode_json); use Test::More;
my $root=tempdir(CLEANUP=>1);
make_path(map {"$root/library/SAS-Useful-Codes/$_"} qw(Easy-For-Error-Codes-SAS SAS_Code_Database Macros));
open my $src,'>',"$root/library/SAS-Useful-Codes/SAS_Code_Database/source.sas" or die $!; print {$src} "data source; x=1; run;\n"; close $src;
make_path("$root/out");
for my $name ('manifest.json','Z0001.sas') {open my $f,'>',"$root/out/$name" or die $!; print {$f} 'previous valid fixture'; close $f;}
sub families {
    my ($fail)=@_; my @f;
    for my $j (1..50) {my $number=$j; push @f,{name=>"family_$j",pattern=>qr/\bdata\b/,
        body=>"data \@P\@o; actual=$j+\@N\@; run;",oracle=>sub {die 'late oracle failure' if $fail && $number==50; $_[0]+$number}};}
    return \@f;
}
my $ok=eval {Library_Evaluation_Corpus::write_corpus(library=>"$root/library",destination=>"$root/out",round=>99,letter=>'Z',start=>1,families=>families(1),description=>'test');1};
ok(!$ok && $@=~/late oracle failure/,'late oracle failure is reported');
for my $name ('manifest.json','Z0001.sas') {open my $f,'<',"$root/out/$name" or die $!; local $/; is(<$f>,'previous valid fixture',"$name preserved on generation failure");}
ok(!-e "$root/out/Z0002.sas",'no partial new program written');
Library_Evaluation_Corpus::write_corpus(library=>"$root/library",destination=>"$root/out",round=>99,letter=>'Z',start=>1,families=>families(0),description=>'test');
open my $mf,'<',"$root/out/manifest.json" or die $!; my $m=do {local $/; decode_json(<$mf>)}; close $mf;
is(scalar @{$m->{cases}},500,'fully validated corpus writes 500 cases');
ok(-f "$root/out/Z0500.sas",'last program is written after successful validation'); done_testing();
