#!/usr/bin/env perl
use strict; use warnings; use FindBin qw($Bin);
use File::Find qw(find); use File::Path qw(make_path); use File::Spec;
use JSON::PP; use Digest::SHA qw(sha256_hex);
my ($books)=@ARGV; die "Usage: $0 BOOK_SAMPLE_DIRECTORY\n" unless defined $books && -d $books;
my @cases;
sub example {push @cases,{name=>$_[0],body=>$_[1],expected=>$_[2],diagnostic=>$_[3],pattern=>$_[4],warning_pattern=>$_[5],lint=>$_[6]//[]};}
my $macro=qr/^\s*%macro\b/i; my $let=qr/^\s*%let\b/i; my $if=qr/^\s*%if\b/i;
example('open_if_then_group',q{%let @P@v=0; %if 1 %then %do; %let @P@v=11; %end;
data @P@o; actual=&@P@v; run; %symdel @P@v;},11,undef,$if);
example('open_if_false_else_group',q{%let @P@v=0; %if 0 %then %do; %let @P@v=-1; %end; %else %do; %let @P@v=12; %end;
data @P@o; actual=&@P@v; run; %symdel @P@v;},12,undef,$if);
example('sequential_open_if_groups',q{%let @P@v=1; %if 1 %then %do; %let @P@v=2; %end;
%if 1 %then %do; %let @P@v=%eval(&@P@v+3); %end;
data @P@o; actual=&@P@v; run; %symdel @P@v;},5,undef,$if);
example('wrapped_indexed_loop',q{%macro @P@m; %local i total; %let total=0; %do i=1 %to 4; %let total=%eval(&total+&i); %end;
data @P@o; actual=&total; run; %mend; %@P@m; %sysmacdelete @P@m;},10,undef,qr/^\s*%do\s+\w+\s*=/i);
example('wrapped_while_loop',q{%macro @P@m; %local i; %let i=1; %do %while(&i<5); %let i=%eval(&i+1); %end;
data @P@o; actual=&i; run; %mend; %@P@m; %sysmacdelete @P@m;},5,undef,qr/%do\s+%while/i);
example('wrapped_until_loop',q{%macro @P@m; %local i; %let i=0; %do %until(&i=3); %let i=%eval(&i+1); %end;
data @P@o; actual=&i; run; %mend; %@P@m; %sysmacdelete @P@m;},3,undef,qr/%do\s+%until/i);
example('local_shadows_global',q{%let @P@v=17; %macro @P@m; %local @P@v; %let @P@v=99; %mend; %@P@m;
data @P@o; actual=&@P@v; run; %symdel @P@v; %sysmacdelete @P@m;},17,undef,qr/^\s*%local\b/i);
example('wrapped_return',q{%macro @P@m; data @P@o; actual=18; run; %return; data @P@o; actual=-1; run; %mend;
%@P@m; %sysmacdelete @P@m;},18,undef,qr/%return\b/i);
example('wrapped_goto',q{%macro @P@m; %goto done; data @P@o; actual=-1; run; %done: data @P@o; actual=19; run; %mend;
%@P@m; %sysmacdelete @P@m;},19,undef,qr/%goto\b/i);
example('uninvoked_macro_local_is_inert',q{%macro @P@m; %local @P@hidden; %let @P@hidden=1; %mend;
data @P@o; actual=%symexist(@P@hidden); run; %sysmacdelete @P@m;},0,undef,$macro);
example('nested_if_inside_macro',q{%macro @P@m; %if 1 %then %do; %if 2>1 %then %do; data @P@o; actual=21; run; %end; %end; %mend;
%@P@m; %sysmacdelete @P@m;},21,undef,$if);
example('str_protects_semicolon',q{%let @P@v=%str(alpha;beta);
data @P@o; actual=index(symget('@P@v'),';'); run; %symdel @P@v;},6,undef,qr/%str\(/i);
example('nrstr_protects_open_controls',q{%let @P@v=%nrstr(%local hidden; %do i=1 %to 2; %end;);
data @P@o; actual=index(symget('@P@v'),'%local'); run; %symdel @P@v;},1,undef,qr/%nrstr\(/i);
example('single_quoted_controls_are_data',q{data @P@o; text='%local hidden; %goto missing; %mend;'; actual=index(text,'%goto'); run;},16,undef,$macro);
example('block_comment_controls',q{/* %local hidden; %do i=1 %to 2; %end; %if 1 %then %put bad; */
data @P@o; actual=25; run;},25,undef,$macro);
example('macro_comment_controls',q{%* %local hidden;
%* %goto nowhere;
data @P@o; actual=26; run;},26,undef,$macro);
example('inline_records_are_not_macro_code',q{data @P@a; input text $char80.; datalines4;
%local hidden; %goto absent; %return;
;;;;
data @P@o; set @P@a; actual=index(text,'%goto'); run;},16,undef,$macro);
example('quoted_nrstr_controls',q{data @P@o; text="%nrstr(%local hidden;)"; actual=index(text,'%local'); run;},1,undef,qr/%nrstr\(/i);
example('macro_option_restoration',q{%let @P@saved=%sysfunc(getoption(merror,keyword)); options merror;
data @P@o; actual=(getoption('merror')='MERROR'); run; options &@P@saved; %symdel @P@saved;},1,undef,qr/%sysfunc\(/i);
example('integer_eval_open_code',q{%let @P@v=%eval((7+3)*2);
data @P@o; actual=&@P@v; run; %symdel @P@v;},20,undef,qr/%eval\(/i);
example('decimal_sysevalf_open_code',q{%let @P@v=%sysevalf(1.5+2.25);
data @P@o; actual=&@P@v; run; %symdel @P@v;},3.75,undef,qr/%sysevalf\(/i);
example('superq_protects_mnemonic',q{%let @P@v=AND; %let @P@same=%eval(%superq(@P@v)=%str(AND));
data @P@o; actual=&@P@same; run; %symdel @P@v @P@same;},1,undef,qr/%superq\(/i);
example('macro_name_delimiter',q{%let @P@v=part;
data @P@o; text="&@P@v._suffix"; actual=(text='part_suffix'); run; %symdel @P@v;},1,undef,$let);
example('indirect_macro_variable',q{%let @P@ptr=@P@value; %let @P@value=34;
data @P@o; actual=&&&@P@ptr; run; %symdel @P@ptr @P@value;},34,undef,$let);
example('symputx_after_run_boundary',q{data _null_; call symputx('@P@v',35,'G'); run;
data @P@o; actual=&@P@v; run; %symdel @P@v;},35,undef,$let);
example('invalid_open_local',q{%local @P@v;},undef,'LOCAL.*not valid in open code',qr/^\s*%local\b/i,undef,['open_code_macro_control']);
example('invalid_open_indexed_do',q{%do @P@i=1 %to 2; %put &@P@i; %end;},undef,'DO.*not valid in open code',qr/^\s*%do\s+\w+\s*=/i,undef,['open_code_do']);
example('invalid_open_while_do',q{%do %while(0); %put never; %end;},undef,'DO.*not valid in open code',qr/%do\s+%while/i,undef,['open_code_do']);
example('invalid_open_until_do',q{%do %until(1); %put once; %end;},undef,'DO.*not valid in open code',qr/%do\s+%until/i,undef,['open_code_do']);
example('invalid_bare_open_do',q{%do; %put bare; %end;},undef,'DO.*not valid in open code',qr/^\s*%do\s*;/i,undef,['open_code_do']);
example('orphan_open_end',q{%end;},undef,'(?:END.*not valid|no matching.*DO)',qr/^\s*%end\s*;/i,undef,['open_code_end']);
example('orphan_open_else',q{%else %do; %put orphan; %end;},undef,'(?:ELSE.*not valid|no matching.*IF)',qr/^\s*%else\b/i,undef,['open_code_else']);
example('orphan_open_then',q{%then %do; %put orphan; %end;},undef,'THEN.*not valid',qr/%then\b/i,undef,['open_code_then']);
example('nested_open_if',q{%if 1 %then %do; %if 1 %then %do; %put nested; %end; %end;},undef,'(?:nesting of.*IF|nested.*IF|IF.*not valid)', $if,undef,['nested_open_code_if']);
example('open_if_requires_do_group',q{%if 1 %then %put direct;
%end;},undef,'Expected %DO not found', $if,undef,['open_code_if_action']);
example('missing_let_semicolon_recursion',q{%let @P@v=1
%put &@P@v;
; %symdel @P@v / nowarn;},undef,'open code statement recursion', $let,undef,['macro_statement_recursion']);
example('invalid_open_goto',q{%goto @P@label;},undef,'GOTO.*not valid in open code',qr/%goto\b/i,undef,['open_code_macro_control']);
example('invalid_open_return',q{%return;},undef,'RETURN.*not valid in open code',qr/%return\b/i,undef,['open_code_macro_control']);
example('orphan_mend',q{%mend;},undef,'(?:no matching.*MACRO|MEND.*not valid)',qr/^\s*%mend\b/i,undef,['open_code_mend']);
example('eval_division_zero',q{%let @P@v=%eval(7/0); %symdel @P@v / nowarn;},undef,'(?:division by zero|divide by zero)',qr/%eval\(/i);
example('eval_decimal_operand',q{%let @P@v=%eval(1.5+2); %symdel @P@v / nowarn;},undef,'(?:character operand|EVAL.*integer)',qr/%eval\(/i);
example('sysfunc_unknown_function',q{%let @P@v=%sysfunc(@P@unknown()); %symdel @P@v / nowarn;},undef,'(?:function.*not found|function.*not.*known|not located)',qr/%sysfunc\(/i);
example('macro_duplicate_parameters',q{%macro @P@m(a,a); %put duplicate; %mend; %sysmacdelete @P@m / nowarn;},undef,'more than one parameter.*same name', $macro);
example('positional_after_keyword_argument',q{%macro @P@m(a=,b=); %put &a &b; %mend; %@P@m(a=1,2); %sysmacdelete @P@m;},undef,'(?:positional.*keyword|keyword.*positional|more positional)', $macro);
example('empty_if_expression_in_macro',q{%macro @P@m; %if %then %put empty; %mend; %@P@m; %sysmacdelete @P@m / nowarn;},undef,'(?:IF.*expression|condition|operand|expression.*missing)', $if);
example('warning_unresolved_symbol',q{options serror; %put NOTE: unresolved=&@P@absent;
data @P@o; actual=46; run;},46,undef,$let,'apparent symbolic reference.*not resolved');
example('warning_unresolved_invocation_in_put',q{options merror; %put NOTE: unresolved=%@P@absent();
data @P@o; actual=47; run;},47,undef,$macro,'apparent invocation of macro.*not resolved');
example('warning_symdel_missing',q{%symdel @P@absent;
data @P@o; actual=48; run;},48,undef,qr/%symdel\b/i,'(?:not found|does not exist|could not be deleted)');
example('warning_sysmacdelete_missing',q{%sysmacdelete @P@absent;
data @P@o; actual=49; run;},49,undef,qr/%sysmacdelete\b/i,'(?:not found|does not exist|could not be deleted)');
example('warning_recursive_parameter_default',q{%macro @P@m(p=&p); %put NOTE: parameter=&p; %mend; %@P@m; %sysmacdelete @P@m;
data @P@o; actual=50; run;},50,undef,$macro,'(?:recursive reference|apparent symbolic reference.*not resolved)');
die 'Expected 50 distinct examples' unless @cases==50;
my @files; find({no_chdir=>1,wanted=>sub {push @files,$File::Find::name if -f $_ && /Macro.*\.txt$/i}},$books);
my @sources=map {open my $f,'<:raw',$_ or die $!; local $/; +{path=>$_,text=><$f>}} sort @files;
my (@programs,%seen);
for my $i (0..$#cases) {
    my $case=$cases[$i]; my $id=sprintf 'M%04d',4001+$i; my $prefix=lc $id;
    my $evidence;
    SOURCE: for my $source (@sources) {my $line=0; for my $text (split /\n/,$source->{text}) {++$line; next unless $text=~$case->{pattern};
        my $relative=File::Spec->abs2rel($source->{path},$books); $relative=~s{\\}{/}g;
        (my $title=$relative)=~s/\.txt$//i;
        $evidence={path=>$relative,line=>$line,book_title=>$title,source_kind=>'book_sample',source_sha256=>sha256_hex($source->{text}),evidence_sha256=>sha256_hex($text)}; last SOURCE;
    }}
    # Older books do not contain every modern helper/statement. Anchor these
    # derived boundary experiments to a real macro definition, explicitly.
    unless ($evidence) {
        SOURCE: for my $source (@sources) {my $line=0; for my $text (split /\n/,$source->{text}) {++$line; next unless $text=~$macro;
            my $relative=File::Spec->abs2rel($source->{path},$books); $relative=~s{\\}{/}g;
            (my $title=$relative)=~s/\.txt$//i;
            $evidence={path=>$relative,line=>$line,book_title=>$title,source_kind=>'book_sample',source_sha256=>sha256_hex($source->{text}),evidence_sha256=>sha256_hex($text),derived_extension=>JSON::PP::true}; last SOURCE;
        }}
    }
    die "No book evidence for $case->{name}" unless $evidence;
    my $body=$case->{body}; $body=~s/\@P\@/$prefix/g;
    my $negative=defined $case->{diagnostic}; my $expected=$case->{expected};
    my $assert=$negative?'':"\ndata _null_; if 0 then set ${prefix}o nobs=rows;\nif rows ne 1 then put 'ERROR: ROUND9_ROWS=$id rows=' rows;\nelse do; set ${prefix}o; if not missing(actual) and abs(actual-($expected))<=1e-9*max(1,abs($expected)) then put 'ROUND9_PASS=$id';\nelse put 'ERROR: ROUND9_FAIL=$id actual=' actual; end; stop; run;\n";
    my $program="/* $id $case->{name}; source: $evidence->{path}:$evidence->{line} */\n$body\n$assert\nproc datasets library=work nolist; delete ${prefix}:; quit;\n";
    my $canonical=$program; $canonical=~s{\A/\*[^\n]*\*/\n}{}; $canonical=~s/M\d{4}/'mCASE'/ige;
    my $hash=sha256_hex($canonical); die "Duplicate $id" if $seen{$hash}++;
    push @programs,[$id,$program];
    $case={id=>$id,file=>"$id.sas",family=>$case->{name},expected=>$expected,expected_failure=>$negative?JSON::PP::true:JSON::PP::false,
        diagnostic=>$case->{diagnostic},warning_pattern=>$case->{warning_pattern},body_sha256=>$hash,evidence=>$evidence,
        tolerance=>'1e-9',expected_lint=>$case->{lint},policy_failure=>$id eq 'M4047'?JSON::PP::true:JSON::PP::false};
    $cases[$i]=$case;
}
my $out="$Bin/../tests/macro_open_code50"; make_path($out);
for my $p (@programs) {open my $f,'>:raw',"$out/$p->[0].sas" or die $!; print {$f} $p->[1]; close $f or die $!;}
open my $f,'>:raw',"$out/manifest.json" or die $!;
print {$f} JSON::PP->new->canonical->pretty->encode({schema=>1,count=>50,round=>9,cases=>\@cases,success_cases=>29,expected_failure_cases=>20,policy_failure_cases=>1,warning_cases=>5}); close $f;
print "Wrote 50 open-code macro examples to $out\n";
