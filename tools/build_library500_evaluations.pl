#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use File::Find qw(find);
use File::Path qw(make_path);
use File::Spec;
use Digest::SHA qw(sha256_hex);
use JSON::PP;
use POSIX qw(ceil floor);
use Time::Local qw(timegm);

# Independent Perl oracles: never snapshot the analyzer's current answer.
my ($library,$destination)=@ARGV;
die "Usage: $0 SASCodesLibrary [OUTPUT_DIRECTORY]\n" unless defined $library && -d $library;
$destination //= "$Bin/../tests/library500";
my @families=qw(abs ceil floor int mod round sign sqrt exp log log10 min max sum mean median range n nmiss coalesce lengthn upcase lowcase strip left reverse substr scan countw countc compress tranwrd translate cats catx index indexc verify count intck datepart year weekday prxmatch prxchange missing input put repeat trim);
die 'Expected 50 families' unless @families==50;
my $wanted=join '|',@families;
my (@paths,%evidence);
# Limit discovery to code libraries, avoiding unrelated books, keys and outputs.
for my $sub (qw(Easy-For-Error-Codes-SAS SAS_Code_Database Macros)) {
    my $dir="$library/SAS-Useful-Codes/$sub";
    die "Missing source directory $dir\n" unless -d $dir;
    find({no_chdir=>1,wanted=>sub {push @paths,$File::Find::name if -f $_ && /\.sas$/i}},$dir);
}
for my $path (sort @paths) {
    open my $fh,'<:raw',$path or die "$path: $!";
    local $/; my $source=<$fh>; close $fh;
    my $line=0;
    for my $text (split /\n/,$source) {
        ++$line;
        while ($text =~ /\b($wanted)\s*\(/ig) {
            my $name=lc $1; next if $evidence{$name};
            my $relative=File::Spec->abs2rel($path,$library); $relative=~s{\\}{/}g;
            $evidence{$name}={path=>$relative,line=>$line,source_sha256=>sha256_hex($source),
                evidence_sha256=>sha256_hex($text),token=>$name};
        }
    }
    last if keys(%evidence)==@families;
}
die "No source evidence for: ".join(',',grep {!$evidence{$_}} @families)."\n"
    if keys(%evidence)!=@families;
make_path($destination);
sub quote_sas {my $s=shift; $s=~s/'/''/g; return "'$s'";}
sub sasdate {return int((timegm(0,0,0,$_[2],$_[1]-1,$_[0])-timegm(0,0,0,1,0,1960))/86400);}
my (@cases,%fingerprints);
for my $family (@families) {
    for my $i (0..9) {
        my ($expr,$expected,$type,$prefix)=('',undef,'numeric','');
        my $x=$i-5.25;
        if ($family eq 'abs') {$expr="abs($x)"; $expected=abs($x);}
        elsif ($family eq 'ceil') {$expr="ceil($x)"; $expected=ceil($x);}
        elsif ($family eq 'floor') {$expr="floor($x)"; $expected=floor($x);}
        elsif ($family eq 'int') {$expr="int($x)"; $expected=int($x);}
        elsif ($family eq 'mod') {my $n=$i-5; $expr="mod($n,3)"; $expected=$n-int($n/3)*3;}
        elsif ($family eq 'round') {$expr="round($x,0.5)"; $expected=($x<0?-1:1)*floor(abs($x)*2+0.5)/2;}
        elsif ($family eq 'sign') {my $n=$i-5; $expr="sign($n)"; $expected=$n<=>0;}
        elsif ($family eq 'sqrt') {$expr='sqrt('.($i*$i).')'; $expected=$i;}
        elsif ($family eq 'exp') {$expr='exp('.($i-5).')'; $expected=exp($i-5);}
        elsif ($family eq 'log') {$expr='log('.($i+1).')'; $expected=log($i+1);}
        elsif ($family eq 'log10') {$expr='log10('.(10**$i).')'; $expected=$i;}
        elsif ($family eq 'min') {$expr="min(.,$i,".(-$i-1).')'; $expected=-$i-1;}
        elsif ($family eq 'max') {$expr="max(.A,$i,".(-$i-1).')'; $expected=$i;}
        elsif ($family eq 'sum') {$expr="sum(.,$i,".($i+3).')'; $expected=2*$i+3;}
        elsif ($family eq 'mean') {$expr="mean(.A,$i,".($i+3).')'; $expected=$i+1.5;}
        elsif ($family eq 'median') {$expr="median(".($i+20).",$i,".($i+2).')'; $expected=$i+2;}
        elsif ($family eq 'range') {$expr="range(.,$i,".($i+2).','.(-$i-1).')'; $expected=2*$i+3;}
        elsif ($family eq 'n') {$expr="n(.,.A,$i,".($i+1).')'; $expected=2;}
        elsif ($family eq 'nmiss') {$expr="nmiss(.,.A,._,$i)"; $expected=3;}
        elsif ($family eq 'coalesce') {$expr="coalesce(.,.A,$i,999)"; $expected=$i;}
        elsif ($family eq 'lengthn') {$expr='lengthn('.quote_sas('x'x$i).')'; $expected=$i;}
        elsif ($family eq 'upcase') {$expr='upcase('.quote_sas("aBc-$i").')'; $expected="ABC-$i"; $type='text';}
        elsif ($family eq 'lowcase') {$expr='lowcase('.quote_sas("AbC-$i").')'; $expected="abc-$i"; $type='text';}
        elsif ($family eq 'strip') {$expr='strip('.quote_sas("  A$i  ").')'; $expected="A$i"; $type='text';}
        elsif ($family eq 'left') {$expr='left('.quote_sas("   B$i").')'; $expected="B$i"; $type='text';}
        elsif ($family eq 'reverse') {$expr='reverse('.quote_sas("ab${i}Z").')'; $expected="Z${i}ba"; $type='text';}
        elsif ($family eq 'substr') {$expr='substr('.quote_sas('abcdefghij').','.($i+1).',1)'; $expected=substr('abcdefghij',$i,1); $type='text';}
        elsif ($family eq 'scan') {my $s=join '|',map {"w$_"} 0..9; $expr='scan('.quote_sas($s).','.($i+1).",'|')"; $expected="w$i"; $type='text';}
        elsif ($family eq 'countw') {my $s=join ' ',map {"w$_"} 0..$i; $expr='countw('.quote_sas($s).')'; $expected=$i+1;}
        elsif ($family eq 'countc') {$expr='countc('.quote_sas(('a'x$i).'BBB').",'a')"; $expected=$i;}
        elsif ($family eq 'compress') {$expr='compress('.quote_sas(" a $i b ").')'; $expected="a${i}b"; $type='text';}
        elsif ($family eq 'tranwrd') {$expr='tranwrd('.quote_sas("one-$i-one").",'one','two')"; $expected="two-$i-two"; $type='text';}
        elsif ($family eq 'translate') {$expr='translate('.quote_sas("ab$i").",'XY','ab')"; $expected="XY$i"; $type='text';}
        elsif ($family eq 'cats') {$expr="cats(' a ',$i,' b ')"; $expected="a${i}b"; $type='text';}
        elsif ($family eq 'catx') {$expr="catx('|',' a ',' ',".quote_sas(" $i ").",' b ')"; $expected="a|$i|b"; $type='text';}
        elsif ($family eq 'index') {$expr='index('.quote_sas(('x'x$i).'needle').",'needle')"; $expected=$i+1;}
        elsif ($family eq 'indexc') {$expr='indexc('.quote_sas(('x'x$i).'AB').",'BA')"; $expected=$i+1;}
        elsif ($family eq 'verify') {$expr='verify('.quote_sas(('a'x$i).'z').",'ab')"; $expected=$i+1;}
        elsif ($family eq 'count') {$expr='count('.quote_sas(('ab'x$i).'Z').",'ab')"; $expected=$i;}
        elsif ($family eq 'intck') {my @mon=qw(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT); $expr="intck('month','15JAN2020'd,'20$mon[$i]2020'd)"; $expected=$i;}
        elsif ($family eq 'datepart') {$expr="datepart('01JAN2020:12:34:56'dt+".($i*86400).')'; $expected=sasdate(2020,1,1)+$i;}
        elsif ($family eq 'year') {$expr="year('01JAN".(1996+$i)."'d)"; $expected=1996+$i;}
        elsif ($family eq 'weekday') {$expr="weekday('01JAN2020'd+$i)"; $expected=($i+3)%7+1;}
        elsif ($family eq 'prxmatch') {
            # SAS requires delimiter escaping even inside a bracket class.
            my @pattern=('/[a\\/]*/','/[*]+/','/[^\\/]*/','/[a\\/]*$/','m/[a\\/]*/','/[a\\/]+/','/[[:alpha:]\\/]*/','/[a\\/]*/i','/[a\\/]*\\//','/[a\\/]*/o');
            my $s=$i==1?'***':$i==8?'aa/':'aaa';
            $prefix="%let l500_prx=%sysfunc(prxmatch($pattern[$i],$s));\n";
            $expr='&l500_prx'; $expected=1;
        }
        elsif ($family eq 'prxchange') {
            my $s=('a'x($i+1)).'z'; $prefix="%let l500_prx=%sysfunc(prxchange(s/[a\\/]*/X/,1,$s));\n";
            $expr=quote_sas('PLACEHOLDER'); $expr='"&l500_prx"'; $expected='Xz'; $type='text';
        }
        elsif ($family eq 'missing') {my @v=('.', '._',map {'.'.chr(65+$_)} 0..7); $expr="missing($v[$i])"; $expected=1;}
        elsif ($family eq 'input') {$expr='input('.quote_sas(sprintf('%03d',17+$i)).',3.)'; $expected=17+$i;}
        elsif ($family eq 'put') {$expr='put('.(17+$i).',z4.)'; $expected=sprintf('%04d',17+$i); $type='text';}
        elsif ($family eq 'repeat') {$expr="repeat('x',$i)"; $expected='x'x($i+1); $type='text';}
        elsif ($family eq 'trim') {$expr='trim('.quote_sas("  q$i   ").')'; $expected="  q$i"; $type='text';}
        else {die "Missing family $family";}
        my $id=sprintf 'L%03d',scalar(@cases)+1;
        my $value=$type eq 'text' ? quote_sas($expected) : sprintf('%.16g',$expected);
        my $condition=$type eq 'text' ? "actual=$value and lengthn(actual)=".length($expected)
            : "not missing(actual) and abs(actual-($value)) <= 1e-11*max(1,abs($value))";
        my $source=$prefix."data _null_;\n".($type eq 'text'?"length actual \$256;\n":'')
            ."actual=$expr;\nif $condition then put 'LIB500_PASS=$id';\n"
            ."else put 'ERROR: LIB500_FAIL=$id actual=' actual;\nrun;\n";
        (my $canonical=$source)=~s/L\d{3}/LCASE/g;
        die "Duplicate executable body $id" if $fingerprints{sha256_hex($canonical)}++;
        my $file="$id.sas";
        open my $out,'>:raw',"$destination/$file" or die $!;
        print {$out} "/* $id: $family boundary $i; source: $evidence{$family}{path}:$evidence{$family}{line} */\n",$source;
        close $out or die $!;
        push @cases,{id=>$id,file=>$file,family=>$family,input_index=>$i,expected=>$expected,type=>$type,
            expression=>$expr,body_sha256=>sha256_hex($canonical),evidence=>$evidence{$family}};
    }
}
open my $mf,'>:raw',"$destination/manifest.json" or die $!;
print {$mf} JSON::PP->new->canonical->pretty->encode({schema=>1,count=>500,
    description=>'50 library-derived behavior families, ten distinct boundary inputs each; Perl-calculated oracles',cases=>\@cases});
close $mf or die $!;
print "Generated ".scalar(@cases)." distinct executable SAS evaluations in $destination\n";
