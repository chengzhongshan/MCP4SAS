#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/lib"; use Library_Evaluation_Corpus;
use Time::Local qw(timegm);
my ($library,$destination)=@ARGV;
die "Usage: $0 SASCodesLibrary [OUTPUT_DIRECTORY]\n" unless defined $library && -d $library;
$destination //= "$Bin/../tests/library500_round6";
my @families;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3],diagnostic=>$_[4]};}
sub date_number {my ($y,$m,$d)=@_; int((timegm(0,0,0,$d,$m-1,$y)-timegm(0,0,0,1,0,1960))/86400)}
my $hash=qr/\b(?:declare|dcl)\s+hash/i;
my $prx=qr/\bprx(?:match|change|parse)\s*\(/i;
my $date=qr/\bdate9\.|\bdatetime\d*\.|\bdatepart\s*\(/i;
family('hash_missing_key_clear',$hash,q{
data @P@a; do k=1 to @N@; value=k; output; end; run;
data @P@o; if 0 then set @P@a; declare hash h(dataset:'@P@a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=@NP1@; call missing(value); rc=h.find(); actual=@N@+(rc ne 0)+missing(value); output; stop; run;
},sub {$_[0]+2});
family('hash_multidata_next',$hash,q{
data @P@a; do k=1 to @N@; value=k; output; value=k+10; output; end; run;
data @P@o; if 0 then set @P@a; declare hash h(dataset:'@P@a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to @N@; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;
},sub {$_[0]*($_[0]+1)+10*$_[0]});
family('hash_iterator_ascending',$hash,q{
data @P@a; do k=@N@ to 1 by -1; output; end; run;
data @P@o; if 0 then set @P@a; declare hash h(dataset:'@P@a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('hash_iterator_descending',$hash,q{
data @P@a; do k=1 to @N@; output; end; run;
data @P@o; if 0 then set @P@a; declare hash h(dataset:'@P@a',ordered:'d'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;
},sub {$_[0]*($_[0]+1)*($_[0]+2)/6});
family('hash_replace_items',$hash,q{
data @P@o; length k value 8; declare hash h(); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to @N@; value=k; rc=h.add(); value=3*k; rc=h.replace(); end;
actual=h.num_items; do k=1 to @N@; rc=h.find(); actual=actual+value; end; output; stop; run;
},sub {$_[0]+3*$_[0]*($_[0]+1)/2});
family('hash_remove_entries',$hash,q{
data @P@o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to @N@; rc=h.add(); end; do k=2 to @N@ by 2; rc=h.remove(); end;
k=2; rc=h.find(); actual=h.num_items+@N@*(rc ne 0); output; stop; run;
},sub {int(($_[0]+1)/2)+$_[0]});
family('hash_clear_all',$hash,q{
data @P@o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to @N@; rc=h.add(); end; before=h.num_items; rc=h.clear(); actual=before+(h.num_items=0); output; stop; run;
},sub {$_[0]+1});
family('hash_output_dataset',$hash,q{
data @P@a; do k=1 to @N@; value=k*k; output; end; run;
data _null_; if 0 then set @P@a; declare hash h(dataset:'@P@a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'@P@b'); stop; run;
proc sql; create table @P@o as select sum(value) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('hash_duplicate_replace_policy',$hash,q{
data @P@a; k=1; value=@N@; output; value=@NP1@; output; run;
data @P@o; if 0 then set @P@a; declare hash h(dataset:'@P@a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;
},sub {$_[0]+2});
family('hash_explicit_key_argument',$hash,q{
data @P@a; do k=1 to @N@; value=2*k; output; end; run;
data @P@o; if 0 then set @P@a; declare hash h(dataset:'@P@a'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do j=1 to @N@; rc=h.find(key:j); if rc=0 then actual=actual+value; end; output; stop; run;
},sub {$_[0]*($_[0]+1)});
family('prxposn_two_groups',$prx,q{
data @P@o; length text $60; text='item@N@:chr@N@'; re=prxparse('/^item([0-9]+):chr([0-9]+)$/'); matched=prxmatch(re,strip(text));
actual=input(prxposn(re,1,strip(text)),best32.)+input(prxposn(re,2,strip(text)),best32.); call prxfree(re); run;
},sub {2*$_[0]});
family('call_prxposn_offsets',$prx,q{
data @P@o; length text $40; text='ID=@N@'; re=prxparse('/ID=([0-9]+)/'); matched=prxmatch(re,text); call prxposn(re,1,pos,len); actual=10*pos+len; call prxfree(re); run;
},sub {40+length($_[0])});
family('call_prxnext_all_matches',$prx,q{
data @P@o; length text $80; text='1 @N@ @NP1@'; re=prxparse('/[0-9]+/'); start=1; stop=lengthn(text); actual=0;
call prxnext(re,start,stop,text,pos,len); do while(pos>0); actual=actual+input(substr(text,pos,len),best32.); call prxnext(re,start,stop,text,pos,len); end; call prxfree(re); run;
},sub {2*$_[0]+2});
family('call_prxsubstr_span',$prx,q{
data @P@o; length text $40; text='xxabc@N@yy'; re=prxparse('/abc[0-9]+/'); call prxsubstr(re,text,pos,len); actual=10*pos+len; call prxfree(re); run;
},sub {33+length($_[0])});
family('prxchange_backreferences',$prx,q{
data @P@o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr@N@:42'); actual=@N@*(text='42-@N@'); run;
},sub {$_[0]});
family('prx_lookahead',$prx,q{
data @P@o; actual=@N@+prxmatch('/[0-9]+(?=bp)/','pos@N@bp'); run;
},sub {$_[0]+4});
family('prx_case_insensitive_replace',$prx,q{
data @P@o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene@N@-gene@N@'); actual=@N@*(text='x@N@-x@N@'); run;
},sub {$_[0]});
family('prx_limit_one_replacement',$prx,q{
data @P@o; length text $40; text=prxchange('s/x/y/',1,'@XS@'); actual=10*countc(text,'y')+countc(text,'x'); run;
},sub {$_[0]+9});
family('findw_case_insensitive',qr/\b(?:findw|scan)\s*\(/i,q{
data @P@o; actual=@N@+findw('gene@N@ X','GENE@N@',' ','i'); run;
},sub {$_[0]+1});
family('countw_empty_tokens',qr/\bcountw\s*\(/i,q{
data @P@o; actual=@N@+countw('a||@N@|','|','m'); run;
},sub {$_[0]+4});
family('scan_empty_token_modifier',qr/\bscan\s*\(/i,q{
data @P@o; actual=input(scan('a||@N@|',3,'|','m'),best32.)+missing(scan('a||@N@|',2,'|','m')); run;
},sub {$_[0]+1});
family('compress_keep_digits',qr/\bcompress\s*\(/i,q{
data @P@o; actual=input(compress('ab@N@cd',,'kd'),best32.); run;
},sub {$_[0]});
family('compress_control_whitespace',qr/\bcompress\s*\(/i,q{
data @P@o; length raw clean $60; raw=' A '||'09'x||'@N@'||'0A'x||' '; clean=compress(raw,,'s'); actual=@N@*(clean='A@N@'); run;
},sub {$_[0]});
family('notdigit_position',qr/\b(?:notdigit|verify)\s*\(/i,q{
data @P@o; length text $40; text=repeat('1',@N@-1)||'x'; actual=notdigit(text); run;
},sub {$_[0]+1});
family('anydigit_position',qr/\b(?:anydigit|verify)\s*\(/i,q{
data @P@o; length text $40; text='@XS@'||'@N@'; actual=anydigit(text); run;
},sub {$_[0]+1});
family('intnx_month_end',$date,q{
data @P@o; actual=intnx('month','15DEC2019'd,@N@,'e'); run;
},sub {date_number(2020,$_[0]+1,1)-1});
family('intnx_quarter_begin',$date,q{
data @P@o; actual=intnx('qtr','15JAN2020'd,@N@,'b'); run;
},sub {date_number(2020+int($_[0]/4),1+3*($_[0]%4),1)});
family('intck_continuous_months',qr/\bintck\s*\(/i,q{
data @P@o; start='15JAN2020'd; endpoint=intnx('month',start,@N@,'same')-1; actual=intck('month',start,endpoint,'c'); run;
},sub {$_[0]-1});
family('intnx_weekday_skip',$date,q{
data @P@o; actual=intnx('weekday','03JAN2020'd,@N@); run;
},sub {my $epoch=timegm(0,0,0,3,0,2020); my $left=$_[0]; while($left) {$epoch+=86400; my $day=(gmtime($epoch))[6]; --$left if $day!=0 && $day!=6;} int(($epoch-timegm(0,0,0,1,0,1960))/86400)});
family('datejul_seven_digit',$date,q{
data @P@o; actual=datejul(2020000+@N@); run;
},sub {date_number(2020,1,1)+$_[0]-1});
family('juldate7_calendar',$date,q{
data @P@o; actual=juldate7('01JAN2020'd+@N@); run;
},sub {2020001+$_[0]});
family('nwkdom_monday',$date,q{
data @P@o; actual=nwkdom(1+mod(@N@,3),2,2,2020); run;
},sub {date_number(2020,2,3+7*($_[0]%3))});
family('mdy_calendar',$date,q{
data @P@o; actual=mdy(@N@,1,2020); run;
},sub {date_number(2020,$_[0],1)});
family('hms_time_roundtrip',$date,q{
data @P@o; length text $8; seconds=hms(@N@,@NP1@,@NP2@); text=put(seconds,time8.); actual=input(text,time8.); run;
},sub {$_[0]*3600+($_[0]+1)*60+$_[0]+2});
family('dhms_attach_date',$date,q{
data @P@o; date='01JAN2020'd+@N@; actual=dhms(date,1,2,3)-date*86400; run;
},sub {3723});
family('frewind_read_again',qr/\bfopen\s*\(/i,q{
filename rtemp temp;
data _null_; file rtemp; put '@N@'; put '@NP1@'; run;
data @P@o; length line $40; fid=fopen('rtemp','i'); rc=fread(fid); rc=fread(fid); rc=frewind(fid); rc=fread(fid); rc=fget(fid,line); actual=input(line,best32.); rc=fclose(fid); run;
filename rtemp clear;
},sub {$_[0]});
family('temp_fexist_lifecycle',qr/\bfexist\s*\(/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'owned @N@'; run;
data @P@a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data @P@o; set @P@a; actual=@N@+present+(fileexist(path)=0); run;
},sub {$_[0]+2});
family('fcopy_owned_temp',qr/\b(?:fcopy|fopen)\s*\(/i,q{
filename srcfile temp; filename dstfile temp;
data _null_; file srcfile; put '@N@'; run;
data _null_; rc=fcopy('srcfile','dstfile'); if rc ne 0 then put 'ERROR: FCOPY fixture failed'; run;
data @P@o; infile dstfile; input actual; run;
filename srcfile clear; filename dstfile clear;
},sub {$_[0]});
family('csv_export_import',qr/proc\s+(?:export|import)/i,q{
data @P@a; do x=1 to @N@; output; end; run;
filename rtemp temp;
proc export data=@P@a outfile=rtemp dbms=csv replace; run;
proc import datafile=rtemp out=@P@b dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table @P@o as select sum(x) as actual from @P@b; quit;
},sub {$_[0]*($_[0]+1)/2});
family('csv_import_quoted_delimiter',qr/proc\s+import/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'x,label'; do x=1 to @N@; put x ',"a,b"'; end; run;
proc import datafile=rtemp out=@P@a dbms=csv replace; getnames=yes; guessingrows=max; run;
filename rtemp clear;
proc sql; create table @P@o as select sum(x)+sum(label='a,b') as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)/2+$_[0]});
family('call_execute_double_quoted_include',qr/call\s+execute/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'data @P@a; value=@N@; run;'; run;
data _null_; call execute("%include rtemp;"); run;
filename rtemp clear;
data @P@o; set @P@a; actual=value; run;
},sub {$_[0]});
family('dosubl_double_quoted_inc',qr/\bdosubl\s*\(/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'data @P@a; value=@N@; run;'; run;
data _null_; rc=dosubl("%inc rtemp;"); run;
filename rtemp clear;
data @P@o; set @P@a; actual=value; run;
},sub {$_[0]});
family('syscall_dataset_binding',qr/%syscall\s+set\s*\(/i,q{
data @P@a; @P@x=@N@; @P@y=@NP1@; run;
%let @P@ds=%sysfunc(open(@P@a,i)); %syscall set(@P@ds);
%let @P@rc=%sysfunc(fetchobs(&@P@ds,1));
data @P@o; actual=&@P@x+&@P@y; run;
%let @P@rc=%sysfunc(close(&@P@ds)); %symdel @P@ds @P@rc @P@x @P@y;
},sub {2*$_[0]+1});
family('symlocal_symglobl_scope',qr/%local\b/i,q{
%let @P@value=@N@;
%macro @P@m(); %local @P@value; %let @P@value=@NP1@;
data @P@a; actual=&@P@value+%symlocal(@P@value)+%symglobl(@P@value); run;
%mend; %@P@m();
data @P@o; set @P@a; actual=actual+&@P@value; run;
%symdel @P@value; %sysmacdelete @P@m;
},sub {2*$_[0]+3});
family('sysfunc_dosubl_program',qr/\bdosubl\s*\(/i,q{
%let @P@rc=%sysfunc(dosubl(data @P@a; value=@N@; run;));
data @P@o; set @P@a; actual=value+&@P@rc; run;
%symdel @P@rc;
},sub {$_[0]});
family('failure_hash_duplicate_error',$hash,q{
data @P@a; do k=1 to @N@; value=k; output; output; end; run;
data @P@b; if 0 then set @P@a; declare hash h(dataset:'@P@a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;
},undef,'(?:duplicate|hash)');
family('failure_transpose_formatted_id',qr/proc\s+transpose/i,q{
proc format library=work; value @P@f low-high='same'; run;
data @P@a; do k=1 to @N@; value=k; output; end; format k @P@f.; run;
proc transpose data=@P@a out=@P@b; id k; var value; run;
proc catalog catalog=work.formats; delete @P@f.format; quit;
},undef,'(?:occurs twice|duplicate)');
family('failure_corr_character_variable',qr/proc\s+corr/i,q{
data @P@a; length text $12; do x=1 to @N@; text='@N@'; output; end; run;
proc corr data=@P@a; var text x; run;
},undef,'(?:type|numeric)');
family('failure_calculated_missing',qr/\bcalculated\b/i,q{
data @P@a; x=@N@; run;
proc sql; create table @P@o as select x,calculated @P@absent as y from @P@a; quit;
},undef,'(?:CALCULATED|not found|not located)');
family('failure_unsorted_by',qr/\bby\b/i,q{
data @P@a; do x=@N@ to 1 by -1; output; end; run;
data @P@b; set @P@a; by x; value=first.x; run;
},undef,'(?:not properly sorted|not sorted)');
Library_Evaluation_Corpus::write_corpus(library=>$library,destination=>$destination,round=>6,letter=>'H',start=>2501,
    families=>\@families,description=>'Hash objects, PRX captures, calendar intervals, file lifecycle, CSV, deferred includes and macro calls; 450 successful and 50 intentional-error cases');
