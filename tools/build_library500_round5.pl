#!/usr/bin/env perl
use strict; use warnings;
use FindBin qw($Bin); use lib "$Bin/lib"; use Library_Evaluation_Corpus;
my ($library,$destination)=@ARGV;
die "Usage: $0 SASCodesLibrary [OUTPUT_DIRECTORY]\n" unless defined $library && -d $library;
$destination //= "$Bin/../tests/library500_round5";
my @families;
sub family {push @families,{name=>$_[0],pattern=>$_[1],body=>$_[2],oracle=>$_[3],diagnostic=>$_[4]};}
family('fetchobs_getvarn',qr/\bfetchobs\s*\(/i,q{
data @P@a; do row=1 to @N@; x=row*row; output; end; run;
data @P@o; ds=open('@P@a','i'); rc=fetchobs(ds,@N@); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;
},sub {$_[0]**2});
family('fetch_sequential',qr/\bfetch\s*\(/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@o; ds=open('@P@a','i'); actual=0; do while(fetch(ds)=0); actual=actual+getvarn(ds,varnum(ds,'x')); end; rc=close(ds); output; stop; run;
},sub {$_[0]*($_[0]+1)/2});
family('getvarc_record',qr/\bgetvarc\s*\(/i,q{
data @P@a; length text $20; do row=1 to @N@; text=cats('row_',row); output; end; run;
data @P@o; length text $20; ds=open('@P@a','i'); rc=fetchobs(ds,@N@); text=getvarc(ds,varnum(ds,'text')); actual=lengthn(text); rc=close(ds); run;
},sub {length('row_'.$_[0])});
family('exist_data_and_view',qr/\bexist\s*\(/i,q{
data @P@a; x=@N@; run;
proc sql; create view @P@v as select * from @P@a; quit;
data @P@o; actual=@N@+exist('@P@a','DATA')+exist('@P@v','VIEW'); run;
proc sql; drop view @P@v; quit;
},sub {$_[0]+2});
family('attrc_dataset_label',qr/\battrc\s*\(/i,q{
data @P@a(label='Dataset @N@'); x=@N@; run;
data @P@o; length text $40; ds=open('@P@a','i'); text=attrc(ds,'LABEL'); actual=lengthn(text); rc=close(ds); run;
},sub {length('Dataset '.$_[0])});
family('dataset_rewind_fetch',qr/\bopen\s*\(/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@o; ds=open('@P@a','i'); rc=fetchobs(ds,@N@); rc=rewind(ds); rc=fetch(ds); actual=getvarn(ds,varnum(ds,'x')); rc=close(ds); run;
},sub {1});
family('call_set_bindings',qr/(?:call|syscall)\s+set\s*\(/i,q{
data @P@a; do row=1 to @N@; x=3*row; output; end; run;
data @P@o; if 0 then set @P@a; ds=open('@P@a','i'); call set(ds); rc=fetchobs(ds,@N@); actual=x; rc=close(ds); output; stop; run;
},sub {3*$_[0]});
family('open_where_fetch',qr/\bopen\s*\(/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
data @P@o; ds=open('@P@a(where=(x>@N@))','i'); actual=0; do while(fetch(ds)=0); actual+1; end; rc=close(ds); output; stop; run;
},sub {$_[0]});
family('physical_logical_observations',qr/\battrn\s*\(/i,q{
data @P@a; do x=1 to 2*@N@; output; end; run;
proc sql; delete from @P@a where mod(x,2)=0; quit;
data @P@o; ds=open('@P@a','i'); actual=attrn(ds,'NOBS')-attrn(ds,'NLOBS'); rc=close(ds); run;
},sub {$_[0]});
family('pdv_character_truncation',qr/\blength\b/i,q{
data @P@a; length text $@N@; text='@XS@'; run;
data @P@o; length text $3; set @P@a; actual=lengthn(text); run;
},sub {$_[0]<3?$_[0]:3});
family('modify_replace',qr/\bmodify\b/i,q{
data @P@a; do k=1 to @N@; value=k; output; end; run;
data @P@a; modify @P@a; value=2*value; replace; run;
proc sql; create table @P@o as select sum(value) as actual from @P@a; quit;
},sub {$_[0]*($_[0]+1)});
family('modify_remove',qr/\bmodify\b/i,q{
data @P@a; do k=1 to 2*@N@; output; end; run;
data @P@a; modify @P@a; if mod(k,2)=0 then remove; run;
proc sql; create table @P@o as select sum(k) as actual from @P@a; quit;
},sub {$_[0]**2});
family('update_missingcheck',qr/\bupdate\b/i,q{
data @P@a; do k=1 to @N@; value=10*k; output; end; run;
data @P@b; do k=1 to @N@; value=.; output; end; run;
data @P@c; update @P@a @P@b; by k; run;
proc sql; create table @P@o as select sum(value) as actual from @P@c; quit;
},sub {5*$_[0]*($_[0]+1)});
family('update_nomissingcheck',qr/\bupdate\b/i,q{
data @P@a; do k=1 to @N@; value=10*k; output; end; run;
data @P@b; do k=1 to @N@; value=.; output; end; run;
data @P@c; update @P@a @P@b updatemode=nomissingcheck; by k; run;
proc sql; create table @P@o as select sum(missing(value)) as actual from @P@c; quit;
},sub {$_[0]});
family('interleaving_set_by',qr/\bset\b/i,q{
data @P@a; do k=1 to @N@; value=k; output; end; run;
data @P@b; do k=1 to @N@; value=10*k; output; end; run;
data @P@c; set @P@a @P@b; by k; weighted=value*_n_; run;
proc sql; create table @P@o as select sum(weighted) as actual from @P@c; quit;
},sub {22*$_[0]*($_[0]+1)*(2*$_[0]+1)/6-$_[0]*($_[0]+1)/2});
family('indexed_set_key',qr/\bkey\s*=/i,q{
data @P@a; do k=1 to @N@; value=k*k; output; end; run;
proc datasets library=work nolist; modify @P@a; index create k; quit;
data @P@b; do k=@N@ to 1 by -1; output; end; run;
data @P@c; set @P@b; set @P@a key=k; if _iorc_=0; run;
proc sql; create table @P@o as select sum(value) as actual from @P@c; quit;
},sub {$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('sort_dupout',qr/\bnodupkey\b/i,q{
data @P@a; do k=1 to @N@; do value=1 to 3; output; end; end; run;
proc sort data=@P@a out=@P@b dupout=@P@c nodupkey equals; by k; run;
proc sql; create table @P@o as select count(*) as actual from @P@c; quit;
},sub {2*$_[0]});
family('sort_noduprecs',qr/proc\s+sort/i,q{
data @P@a; do k=1 to @N@; value=1; output; output; value=2; output; end; run;
proc sort data=@P@a out=@P@b noduprecs; by _all_; run;
proc sql; create table @P@o as select count(*) as actual from @P@b; quit;
},sub {2*$_[0]});
family('sort_tagsort',qr/proc\s+sort/i,q{
data @P@a; do x=@N@ to 1 by -1; output; end; run;
proc sort data=@P@a out=@P@b tagsort; by x; run;
data @P@o; set @P@b end=last; if last; actual=x; run;
},sub {$_[0]});
family('rank_high_ties',qr/proc\s+rank/i,q{
data @P@a; do x=1 to @N@; output; output; end; run;
proc rank data=@P@a out=@P@b ties=high; var x; ranks position; run;
proc sql; create table @P@o as select sum(position) as actual from @P@b; quit;
},sub {2*$_[0]*($_[0]+1)});
family('special_missing_sort_order',qr/proc\s+sort/i,q{
data @P@a; x=.Z; output; x=.; output; x=._; output; x=.A; output; x=@N@; output; run;
proc sort data=@P@a out=@P@b; by x; run;
data @P@o; set @P@b; if _n_=1; actual=@N@+(x=._); run;
},sub {$_[0]+1});
family('temporary_array_retention',qr/\b_temporary_\b/i,q{
data @P@a; do x=1 to @N@; output; end; run;
data @P@o; set @P@a end=last; array sums[2] _temporary_ (0 0); sums[1]+x; sums[2]+x*x; if last; actual=sums[1]+sums[2]; run;
},sub {$_[0]*($_[0]+1)/2+$_[0]*($_[0]+1)*(2*$_[0]+1)/6});
family('implicit_array_do_over',qr/\barray\b/i,q{
data @P@o; x1=@N@; x2=@NP1@; x3=@NP2@; array vals x1-x3; do over vals; vals=2*vals; end; actual=sum(of x1-x3); run;
},sub {6*$_[0]+6});
family('character_array_cmiss',qr/\barray\b/i,q{
data @P@o; array vals[@N@] $3 c1-c@N@; do j=1 to @N@; if mod(j,2) then vals[j]='x'; end; actual=cmiss(of vals[*]); run;
},sub {int($_[0]/2)});
family('numeric_variable_list',qr/\b_numeric_\b/i,q{
data @P@a; length label $20; label='ignore'; array vals[@N@] v1-v@N@; do j=1 to @N@; vals[j]=@N@; end; drop j; run;
data @P@o; set @P@a; actual=sum(of _numeric_); run;
},sub {$_[0]**2});
family('tab_delimited_input',qr/\bdlm\s*=/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'alpha' '09'x '@N@'; run;
data @P@o; infile rtemp dlm='09'x dsd; input label :$20. actual; run;
filename rtemp clear;
},sub {$_[0]});
family('pipe_quoted_field',qr/\bdsd\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put '"a|b"|@N@'; run;
data @P@o; length label $20; infile rtemp dlm='|' dsd; input label :$20. value; actual=value+lengthn(label); run;
filename rtemp clear;
},sub {$_[0]+3});
family('input_slash_pointer',qr/\binput\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put '@N@'; put '@NP1@'; run;
data @P@o; infile rtemp; input a / b; actual=a+b; run;
filename rtemp clear;
},sub {2*$_[0]+1});
family('input_column_pointer',qr/\binput\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'xx@N@'; run;
data @P@o; infile rtemp; input @3 actual; run;
filename rtemp clear;
},sub {$_[0]});
family('named_input_values',qr/\binput\b/i,q{
data @P@o; input a= b=; actual=a+b; datalines;
a=@N@ b=@NP1@
;
run;
},sub {2*$_[0]+1});
family('single_at_conditional_input',qr/\binput\b.*@/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'skip junk'; put 'keep @N@'; put 'keep @NP1@'; run;
data @P@a; infile rtemp; input key $ @; if key='keep' then input value; else delete; run;
filename rtemp clear;
proc sql; create table @P@o as select sum(value) as actual from @P@a; quit;
},sub {2*$_[0]+1});
family('infile_record_length',qr/\binfile\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'record_@N@'; run;
data @P@o; infile rtemp length=reclen; input; actual=reclen; run;
filename rtemp clear;
},sub {length('record_'.$_[0])});
family('infile_buffer',qr/\b_infile_\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put '@XS@'; run;
data @P@o; infile rtemp; input; actual=countc(_infile_,'x'); run;
filename rtemp clear;
},sub {$_[0]});
family('datalines4_apostrophe',qr/\b(?:datalines4|cards4)\b/i,q{
data @P@o; infile datalines4 truncover; input text $char80.; actual=lengthn(text); datalines4;
O'Brien;@N@
;;;;
run;
},sub {length("O'Brien;$_[0]")});
family('missover_multiple_records',qr/\bmissover\b/i,q{
filename rtemp temp;
data _null_; file rtemp; put '@N@'; put '@NP1@ 7'; run;
data @P@a; infile rtemp missover; input a b; run;
filename rtemp clear;
proc sql; create table @P@o as select sum(a)+sum(missing(b)) as actual from @P@a; quit;
},sub {2*$_[0]+2});
family('qsubstr_protected_comma',qr/%qsubstr\s*\(/i,q{
%let @P@text=%nrstr(a,b,@N@,z);
%let @P@part=%qsubstr(%superq(@P@text),5,@NDIGITS@);
data @P@o; actual=input(symget('@P@part'),best32.); run;
%symdel @P@text @P@part;
},sub {$_[0]});
family('qupcase_literal_triggers',qr/%qupcase\s*\(/i,q{
%let @P@text=%nrstr(a&bad%ghost@N@);
%let @P@upper=%qupcase(%superq(@P@text));
data @P@o; length text $50; text=symget('@P@upper'); actual=@N@*(text='A&BAD%GHOST@N@'); run;
%symdel @P@text @P@upper;
},sub {$_[0]});
family('nrbquote_resolved_apostrophe',qr/%nrbquote\s*\(/i,q{
data _null_; call symputx('@P@raw','O''Brien@N@','g'); run;
%let @P@quoted=%nrbquote(&@P@raw);
data @P@o; length text $50; text=symget('@P@quoted'); actual=lengthn(text); run;
%symdel @P@raw @P@quoted;
},sub {length("O'Brien$_[0]")});
family('sysevalf_ceiling',qr/%sysevalf\s*\(/i,q{
%let @P@value=%sysevalf(@N@/4,ceil);
data @P@o; actual=&@P@value; run;
%symdel @P@value;
},sub {int(($_[0]+3)/4)});
family('eval_boolean_expression',qr/%eval\s*\(/i,q{
%let @P@value=%eval((@N@>5) and (%sysfunc(mod(@N@,2))=0));
data @P@o; actual=&@P@value; run;
%symdel @P@value;
},sub {$_[0]>5 && $_[0]%2==0?1:0});
family('macro_euclid_loop',qr/%do\s+%while/i,q{
%macro @P@m(); %local a b r; %let a=@N@; %let b=@NP2@;
%do %while(&b>0); %let r=%sysfunc(mod(&a,&b)); %let a=&b; %let b=&r; %end;
data @P@o; actual=&a; run;
%mend; %@P@m(); %sysmacdelete @P@m;
},sub {$_[0]%2?1:2});
family('macro_keyword_default_comma',qr/%macro\b/i,q{
%macro @P@m(list=%str(key,@N@)); %local part; %let part=%qscan(%superq(list),2,%str(,));
data @P@o; actual=input(symget('part'),best32.); run;
%mend; %@P@m(); %sysmacdelete @P@m;
},sub {$_[0]});
family('sysmacexist_after_delete',qr/%sysmacexist\s*\(/i,q{
%macro @P@m(); @N@ %mend;
%let @P@before=%sysmacexist(@P@m); %sysmacdelete @P@m;
data @P@o; actual=@N@+&@P@before+%sysmacexist(@P@m); run;
%symdel @P@before;
},sub {$_[0]+1});
family('inc_temporary_fileref',qr/%inc\s/i,q{
filename rtemp temp;
data _null_; file rtemp; put 'data @P@o; actual=@N@*7; run;'; run;
%inc rtemp;
filename rtemp clear;
},sub {7*$_[0]});
family('inc_two_filerefs',qr/%inc\s/i,q{
filename inc1 temp; filename inc2 temp;
data _null_; file inc1; put 'data @P@a; x=@N@; run;'; run;
data _null_; file inc2; put 'data @P@b; y=@NP1@; run;'; run;
%inc inc1 inc2;
filename inc1 clear; filename inc2 clear;
data @P@o; set @P@a; set @P@b; actual=x+y; run;
},sub {2*$_[0]+1});
family('failure_unique_index',qr/index\s+create|create\s+index/i,q{
data @P@a; do k=1 to @N@; output; output; end; run;
proc datasets library=work nolist; modify @P@a; index create k / unique; quit;
},undef,'(?:duplicate|index)');
family('failure_set_type_conflict',qr/\bset\b/i,q{
data @P@a; value=@N@; run;
data @P@b; length value $12; value='@N@'; run;
data @P@c; set @P@a @P@b; run;
},undef,'(?:character|numeric|type)');
family('failure_summary_where',qr/proc\s+sql/i,q{
data @P@a; do x=1 to @N@; output; end; run;
proc sql; create table @P@o as select x from @P@a where sum(x)>@N@; quit;
},undef,'(?:summary|aggregate|WHERE)');
family('failure_insert_arity',qr/insert\s+into/i,q{
data @P@a; x=@N@; y=@NP1@; run;
proc sql; insert into @P@a(x,y) values(@N@); quit;
},undef,'(?:columns|values|value|number)');
family('failure_format_overlap',qr/proc\s+format/i,q{
proc format library=work; value @P@f 1-@NP2@='first' @N@-@NX2@='second'; run;
data _null_; if cexist('work.formats.@P@f.format') then call execute('proc catalog catalog=work.formats; delete @P@f.format; quit;'); run;
},undef,'(?:overlap|range|repeated)');
Library_Evaluation_Corpus::write_corpus(library=>$library,destination=>$destination,round=>5,letter=>'G',start=>2001,
    families=>\@families,description=>'Dataset handles, in-place changes, structured input, macro quoting and include abbreviations; 450 positive and 50 expected-error scenarios');
