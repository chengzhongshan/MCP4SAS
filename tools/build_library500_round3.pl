#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin);
use File::Find qw(find);
use File::Spec;
use File::Path qw(make_path);
use Digest::SHA qw(sha256_hex);
use JSON::PP;
use Time::Local qw(timegm);
my ($library,$destination)=@ARGV;
die "Usage: $0 SASCodesLibrary [OUTPUT_DIRECTORY]\n" unless defined $library && -d $library;
$destination //= "$Bin/../tests/library500_round3";
my @families;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3],catalog=>$_[4]};}
family('contents_variable_count',qr/proc\s+contents/i,q{
data @P@a; array x[@N@] v1-v@N@; do j=1 to @N@; x[j]=j; end; drop j; run;
proc contents data=@P@a out=@P@b noprint; run;
proc sql; create table @P@o as select count(*) as actual from @P@b; quit;
},sub {$_[0]});
family('contents_character_length',qr/proc\s+contents/i,q{
data @P@a; length text $@N@; text='a'; run;
proc contents data=@P@a out=@P@b noprint; run;
data @P@o; set @P@b; actual=length; run;
},sub {$_[0]});
family('contents_label_text',qr/\blabel\b/i,q{
data @P@a; x=@N@; label x='Field_@N@'; run;
proc contents data=@P@a out=@P@b noprint; run;
data @P@o; set @P@b; actual=lengthn(label); run;
},sub {length('Field_'.$_[0])});
family('open_varnum',qr/\bvarnum\s*\(/i,q{
data @P@a; array x[@N@] v1-v@N@; do j=1 to @N@; x[j]=j; end; drop j; run;
data @P@o; ds=open('@P@a','i'); actual=varnum(ds,'v@N@'); rc=close(ds); run;
},sub {$_[0]});
family('open_vartype',qr/\bvartype\s*\(/i,q{
data @P@a; length text $@N@; text='a'; value=@N@; run;
data @P@o; ds=open('@P@a','i'); actual=@N@+10*(vartype(ds,varnum(ds,'text'))='C'); rc=close(ds); run;
},sub {$_[0]+10});
family('open_varlen',qr/\bvarlen\s*\(/i,q{
data @P@a; length text $@NP5@; text='a'; run;
data @P@o; ds=open('@P@a','i'); actual=varlen(ds,varnum(ds,'text')); rc=close(ds); run;
},sub {$_[0]+5});
family('open_varlabel_quote',qr/\bvarlabel\s*\(/i,q{
data @P@a; value=@N@; label value="Owner's field @N@"; run;
data @P@o; length label $80; ds=open('@P@a','i'); label=varlabel(ds,1); actual=lengthn(label); rc=close(ds); run;
},sub {length("Owner's field $_[0]")});
family('attrn_record_length',qr/\battrn\s*\(/i,q{
data @P@a; array x[@N@] v1-v@N@; do j=1 to @N@; x[j]=j; end; drop j; run;
data @P@o; ds=open('@P@a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;
},sub {8*$_[0]});
family('dictionary_index_count',qr/dictionary\.indexes|create\s+index/i,q{
data @P@a; array x[@N@] v1-v@N@; do j=1 to @N@; x[j]=j; end; drop j; run;
%macro @P@m; proc datasets library=work nolist; modify @P@a; %do i=1 %to @N@; index create v&i; %end; quit; %mend; %@P@m;
%sysmacdelete @P@m;
proc sql; create table @P@o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('@P@a'); quit;
},sub {$_[0]});
family('dictionary_empty_table',qr/dictionary\.tables/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; set @P@a(obs=0); run;
proc sql; create table @P@o as select sum(nobs) as actual from dictionary.tables where libname='WORK' and (memname=upcase('@P@a') or memname=upcase('@P@b')); quit;
},sub {$_[0]});
family('numeric_range_format',qr/proc\s+format/i,q{
proc format library=work; value @P@f low-0='nonpositive' 1-high='positive'; run;
data @P@a; do x=-@N@ to @N@; matched=(put(x,@P@f.)='positive'); output; end; run;
proc sql; create table @P@o as select sum(matched) as actual from @P@a; quit;
},sub {$_[0]},'format');
family('character_format_lookup',qr/\bvalue\s+\$/i,q{
proc format library=work; value $@P@f 'A@N@'='alpha' other='other'; run;
data @P@o; actual=@N@+100*(put('A@N@',$@P@f.)='alpha'); run;
},sub {$_[0]+100},'formatc');
family('user_informat',qr/\binvalue\b/i,q{
proc format library=work; invalue @P@f 'code@N@'=@NX3@ other=.; run;
data @P@o; actual=input('code@N@',@P@f.); run;
},sub {3*$_[0]},'informat');
family('cntlin_generated_format',qr/\bcntlin\s*=/i,q{
data @P@a; length fmtname $32 type $1 label $20; fmtname='@P@f'; type='N'; do start=1 to @N@; end=start; label=strip(put(2*start,best32.)); output; end; run;
proc format library=work cntlin=@P@a; run;
data @P@o; actual=input(putn(@N@,'@P@f.'),best32.); run;
},sub {2*$_[0]},'format');
family('cntlout_roundtrip',qr/\bcntlout\s*=/i,q{
proc format library=work cntlout=@P@a; value @P@f 1='first' @NP1@='last'; run;
proc sql; create table @P@o as select sum(input(start,best32.)) as actual from @P@a where upcase(fmtname)=upcase('@P@f'); quit;
},sub {$_[0]+2},'format');
family('comma_format_roundtrip',qr/\bcomma\d*\./i,q{
data @P@o; length text $20; value=1001*@N@; text=put(value,comma20.); actual=input(text,comma20.); run;
},sub {1001*$_[0]});
family('format_assignment_metadata',qr/\bformat\b/i,q{
data @P@a; value=@N@; format value z8.; run;
proc contents data=@P@a out=@P@b noprint; run;
data @P@o; set @P@b; actual=@N@+10*(format='Z')+formatl; run;
},sub {$_[0]+18});
family('informat_assignment_metadata',qr/\binformat\b/i,q{
data @P@a; value=@N@; informat value best32.; run;
proc contents data=@P@a out=@P@b noprint; run;
data @P@o; set @P@b; actual=@N@+informl; run;
},sub {$_[0]+32});
family('append_force_extra_column',qr/proc\s+append/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; do x=1 to @N@; extra=x; output; end; run;
proc append base=@P@a data=@P@b force; run;
proc sql; create table @P@o as select sum(x) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)});
family('set_rename_swap',qr/\brename\s*=/i,q{
data @P@a; x=@N@; y=@NP1@; run;
data @P@o; set @P@a(rename=(x=oldx y=x)); actual=10*x+oldx; run;
},sub {11*$_[0]+10});
family('where_before_iteration',qr/\bwhere\b/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
data @P@b; set @P@a(where=(mod(x,2)=0)); if _n_=1; run;
data @P@c; set @P@a; if mod(x,2)=0 and _n_=1; run;
proc sql; create table @P@d as select sum(x) as subtotal from @P@b;
create table @P@e as select count(*) as subtotal from @P@c;
create table @P@o as select b.subtotal+c.subtotal as actual from @P@d b,@P@e c; quit;
},sub {2});
family('firstobs_obs_window',qr/\bfirstobs\s*=/i,q{
data @P@a; do x=1 to 2*@N@+2; output; end; run;
data @P@b; set @P@a(firstobs=@N@ obs=@NP2@); run;
proc sql; create table @P@o as select sum(x) as actual from @P@b; quit;
},sub {3*$_[0]+3});
family('obs_zero_schema',qr/\bobs\s*=\s*0/i,q{
data @P@a; array x[@N@] v1-v@N@; do j=1 to @N@; x[j]=j; end; drop j; run;
data @P@b; set @P@a(obs=0); run;
data @P@o; ds=open('@P@b','i'); actual=attrn(ds,'NVARS')+attrn(ds,'NLOBS'); rc=close(ds); run;
},sub {$_[0]});
family('summary_missing_class',qr/proc\s+(?:summary|means)/i,q{
data @P@a; do grp=1 to @N@; value=1; output; end; grp=.; output; run;
proc summary data=@P@a nway missing; class grp; var value; output out=@P@b sum=total; run;
proc sql; create table @P@o as select sum(total) as actual from @P@b; quit;
},sub {$_[0]+1});
family('freq_zero_weight',qr/\bweight\b/i,q{
data @P@a; do grp=0 to @N@; weight=grp; output; end; run;
proc freq data=@P@a noprint; tables grp / out=@P@b; weight weight / zeros; run;
proc sql; create table @P@o as select count(*) as actual from @P@b; quit;
},sub {$_[0]+1});
family('rank_descending_low_ties',qr/proc\s+rank/i,q{
data @P@a; do x=1 to @N@; output; output; end; run;
proc rank data=@P@a out=@P@b descending ties=low; var x; ranks position; run;
proc sql; create table @P@o as select sum(position) as actual from @P@b; quit;
},sub {2*$_[0]**2});
family('transpose_let_last_value',qr/proc\s+transpose/i,q{
data @P@a; do value=1 to @N@; id=1; output; end; run;
proc transpose data=@P@a out=@P@b let prefix=v; id id; var value; run;
data @P@o; set @P@b; actual=v1; run;
},sub {$_[0]});
family('outer_union_corr',qr/outer\s+union/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@b; do y=1 to @N@; output; end; run;
proc sql; create table @P@c as select x from @P@a outer union corr select y from @P@b;
create table @P@o as select sum(x)+sum(y) as actual from @P@c; quit;
},sub {$_[0]*($_[0]+1)});
family('sql_view_reexecute',qr/\bcreate\s+view/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql; create view @P@v as select * from @P@a; quit;
data @P@a; do x=1 to 2*@N@; output; end; run;
proc sql; create table @P@o as select count(*) as actual from @P@v; drop view @P@v; quit;
},sub {2*$_[0]});
family('datastep_view_lazy',qr/\bview\s*=/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@v / view=@P@v; set @P@a; value=2*x; run;
data @P@a; do x=1 to @NP1@; output; end; run;
proc sql; create table @P@o as select sum(value) as actual from @P@v; drop view @P@v; quit;
},sub {($_[0]+1)*($_[0]+2)});
family('date_between_window',qr/\bbetween\b/i,q{
data @P@a; do day=0 to 2*@N@; date='01JAN2020'd+day; output; end; run;
proc sql; create table @P@o as select count(*) as actual from @P@a where date between '01JAN2020'd+@N@ and '01JAN2020'd+2*@N@; quit;
},sub {$_[0]+1});
family('sql_like_escape',qr/\blike\b/i,q{
data @P@a; length text $20; text='a_@N@'; value=@N@; output; text='aX@N@'; value=100; output; run;
proc sql; create table @P@o as select sum(value) as actual from @P@a where text like 'a^_%' escape '^'; quit;
},sub {$_[0]});
family('sql_not_in_missing',qr/\bnot\s+in\s*\(/i,q{
data @P@a; do x=1 to @N@; output; end; x=.; output; run;
proc sql; create table @P@o as select sum(x) as actual from @P@a where x not in (.,@N@); quit;
},sub {$_[0]*($_[0]-1)/2});
family('sql_column_order',qr/\bvarnum\s*\(|column\s+order/i,q{
data @P@a; x=@N@; y=@NP1@; run;
proc sql; create table @P@b as select y,x from @P@a; quit;
data @P@o; ds=open('@P@b','i'); actual=@N@+varnum(ds,'x'); rc=close(ds); run;
},sub {$_[0]+2});
family('sql_outobs_window',qr/\boutobs\s*=/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
proc sql outobs=@N@; create table @P@b as select * from @P@a order by x desc; quit;
proc sql; create table @P@o as select sum(x) as actual from @P@b; quit;
},sub {$_[0]*(3*$_[0]+1)/2});
family('leap_date_informat',qr/\bdate9\./i,q{
data @P@o; actual=input('29FEB@YEAR@',date9.); run;
},sub {int((timegm(0,0,0,29,1,1980+4*($_[0]-2))-timegm(0,0,0,1,0,1960))/86400)});
family('datetime_components',qr/\bdatetime\d*\.|\bdatepart\s*\(/i,q{
data @P@o; stamp=input('01JAN@YEAR@:12:34:56',datetime20.); actual=datepart(stamp)+timepart(stamp); run;
},sub {int((timegm(0,0,0,1,0,1980+4*($_[0]-2))-timegm(0,0,0,1,0,1960))/86400)+45296});
family('leap_day_interval',qr/\bintck\s*\(/i,q{
data @P@o; actual=intck('day','28FEB@YEAR@'d,'01MAR@YEAR@'d); run;
},sub {2});
family('weekend_date_filter',qr/\bweekday\s*\(/i,q{
data @P@a; do day=0 to 28*@N@-1; date='01JAN2020'd+day; if weekday(date) in (1,7) then output; end; run;
proc sql; create table @P@o as select count(*) as actual from @P@a; quit;
},sub {8*$_[0]});
family('unquote_releases_nrstr',qr/%unquote\s*\(/i,q{
%macro @P@m(); %eval(3*@N@) %mend;
%let @P@value=%unquote(%nrstr(%@P@m()));
data @P@o; actual=input(symget('@P@value'),best32.); run;
%symdel @P@value; %sysmacdelete @P@m;
},sub {3*$_[0]});
family('macro_indirect_array',qr/&&/i,q{
%macro @P@m(); %local i; %do i=1 %to @N@; %local @P@v&i; %let @P@v&i=&i; %end;
data @P@o; actual=0; %do i=1 %to @N@; actual=actual+&&@P@v&i; %end; run;
%mend; %@P@m(); %sysmacdelete @P@m;
},sub {$_[0]*($_[0]+1)/2});
family('qscan_quoted_comma',qr/%qscan\s*\(/i,q{
%let @P@list=x,"a,@N@",z;
%let @P@selected=%qscan(%superq(@P@list),2,%str(,),q);
data @P@o; length text $30; text=symget('@P@selected'); actual=lengthn(text); run;
%symdel @P@list @P@selected;
},sub {length('"a,'.$_[0].'"')});
family('symputx_local_scope',qr/\bsymputx\s*\(/i,q{
%let @P@value=77;
%macro @P@m(); %local @P@value; data _null_; call symputx('@P@value',@N@,'l'); run;
data @P@a; inner=&@P@value; run; %mend; %@P@m();
data @P@o; set @P@a; actual=inner+&@P@value; run;
%symdel @P@value; %sysmacdelete @P@m;
},sub {$_[0]+77});
family('symexist_after_symdel',qr/%symexist\s*\(/i,q{
%let @P@value=@N@;
data @P@a; actual=&@P@value+%symexist(@P@value); run;
%symdel @P@value;
data @P@o; set @P@a; actual=actual+%symexist(@P@value); run;
},sub {$_[0]+1});
family('macro_descending_loop',qr/%do\b/i,q{
%macro @P@m(); %local i; data @P@a; %do i=@N@ %to 1 %by -1; x=&i; output; %end; run; %mend; %@P@m();
%sysmacdelete @P@m;
data @P@b; set @P@a; value=x*_n_; run;
proc sql; create table @P@o as select sum(value) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)*($_[0]+2)/6});
family('sysfunc_dataset_handle',qr/%sysfunc\s*\(\s*open\s*\(/i,q{
data @P@a; do x=1 to @N@; output; end; run;
%let @P@ds=%sysfunc(open(@P@a,i));
%let @P@count=%sysfunc(attrn(&@P@ds,NLOBS));
%let @P@rc=%sysfunc(close(&@P@ds));
data @P@o; actual=&@P@count; run;
%symdel @P@ds @P@count @P@rc;
},sub {$_[0]});
family('prxparse_datastep_handle',qr/\bprxparse\s*\(/i,q{
data @P@o; pattern=prxparse('/^[0-9]+$/'); actual=@N@+prxmatch(pattern,'@N@'); call prxfree(pattern); run;
},sub {$_[0]+1});
family('fopen_fread_fget',qr/\bfread\s*\(/i,q{
filename rtemp temp;
data _null_; file rtemp; do x=1 to @N@; put x; end; run;
data @P@o; length line $100; fid=fopen('rtemp','i'); actual=0;
if fid>0 then do; do while(fread(fid)=0); rc=fget(fid,line); actual=actual+input(line,best32.); end; rc=fclose(fid); end;
else actual=.; output; stop; run;
filename rtemp clear;
},sub {$_[0]*($_[0]+1)/2});
family('fileref_assignment_status',qr/\bfileref\s*\(/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'owned status @N@'; run;
data @P@a; active=fileref('rtemp'); run;
filename rtemp clear;
data @P@o; set @P@a; actual=@N@+(active=0)+(fileref('rtemp') ne 0); run;
},sub {$_[0]+2});
family('fdelete_owned_temp_file',qr/\bfdelete\s*\(/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'owned test @N@'; run;
data @P@o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=@N@+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;
},sub {$_[0]+2});
die 'Expected 50 families' unless @families==50;
my @files;
for my $sub (qw(Easy-For-Error-Codes-SAS SAS_Code_Database Macros)) {
    my $dir="$library/SAS-Useful-Codes/$sub"; die "Missing $dir" unless -d $dir;
    find({no_chdir=>1,wanted=>sub {push @files,$File::Find::name if -f $_ && /\.sas$/i}},$dir);
}
for my $path (sort @files) {
    open my $fh,'<:raw',$path or die "$path: $!"; local $/; my $source=<$fh>; close $fh;
    my $line=0;
    for my $text (split /\n/,$source) {
        ++$line;
        for my $family (@families) {
            next if $family->{evidence};
            if ($text =~ $family->{pattern}) {
                my $relative=File::Spec->abs2rel($path,$library); $relative=~s{\\}{/}g;
                $family->{evidence}={path=>$relative,line=>$line,source_sha256=>sha256_hex($source),evidence_sha256=>sha256_hex($text)};
            }
        }
    }
    last unless grep {!$_->{evidence}} @families;
}
die 'Missing evidence: '.join(',',map {$_->{name}} grep {!$_->{evidence}} @families)."\n" if grep {!$_->{evidence}} @families;
make_path($destination);
my (@cases,%seen);
for my $family (@families) {
    for my $n (2..11) {
        my $id=sprintf 'T%04d',1001+@cases; my $prefix=lc $id;
        my $body=$family->{body};
        my %replace=('@P@'=>$prefix,'@N@'=>$n,'@NP1@'=>$n+1,'@NP2@'=>$n+2,'@NP5@'=>$n+5,'@NX3@'=>3*$n,'@YEAR@'=>1980+4*($n-2));
        $body=~s/(\@(?:P|N|NP1|NP2|NP5|NX3|YEAR)\@)/$replace{$1}/ge;
        my $expected=$family->{oracle}->($n);
        my $cleanup='';
        if ($family->{catalog}) {
            my $kind=$family->{catalog} eq 'informat'?'infmt':$family->{catalog} eq 'formatc'?'formatc':'format';
            my $entry="${prefix}f";
            $cleanup="proc catalog catalog=work.formats; delete $entry.$kind; quit;\n";
        }
        my $source="/* $id $family->{name}, N=$n; source: $family->{evidence}{path}:$family->{evidence}{line} */\n$body\n"
            ."data _null_; if 0 then set ${prefix}o nobs=rows;\nif rows ne 1 then put 'ERROR: ROUND3_ROWS=$id rows=' rows;\n"
            ."else do; set ${prefix}o; if not missing(actual) and abs(actual-($expected))<=1e-10*max(1,abs($expected)) then put 'ROUND3_PASS=$id';\n"
            ."else put 'ERROR: ROUND3_FAIL=$id actual=' actual; end; stop; run;\n"
            ."proc datasets library=work nolist; delete ${prefix}:; quit;\n$cleanup";
        my $canonical=$source; $canonical=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/t\d{4}/tCASE/ig;
        my $fingerprint=sha256_hex($canonical); die "Duplicate $id" if $seen{$fingerprint}++;
        open my $out,'>:raw',"$destination/$id.sas" or die $!; print {$out} $source; close $out or die $!;
        push @cases,{id=>$id,file=>"$id.sas",family=>$family->{name},input_n=>$n,expected=>$expected,
            body_sha256=>$fingerprint,evidence=>$family->{evidence},tables_prefix=>$prefix};
    }
}
open my $mf,'>:raw',"$destination/manifest.json" or die $!;
print {$mf} JSON::PP->new->canonical->pretty->encode({schema=>1,count=>500,round=>3,
    description=>'50 metadata, format, view, date, macro-quoting and file-handle families, ten scenarios each',cases=>\@cases});
close $mf or die $!;
print "Wrote ".scalar(@cases)." third-round SAS evaluations to $destination\n";
