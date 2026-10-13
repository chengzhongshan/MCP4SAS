#!/usr/bin/env perl
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use File::Basename qw(basename);
use Getopt::Long qw(GetOptions);
use JSON::PP qw(encode_json decode_json);
use Mojo::UserAgent;
use Digest::SHA qw(sha256_hex);
$| = 1;

my ($live, $generate, $only, $out) = (0, 0, '', '');
my $batch = 1;
my $library_root = '';
my $url = 'http://127.0.0.1:18130/mcp';
GetOptions('live' => \$live, 'generate-only' => \$generate, 'only=s' => \$only,
    'out=s' => \$out, 'url=s' => \$url, 'batch=i' => \$batch,
    'library-root=s' => \$library_root) or die "Invalid options\n";
die "Use --live or --generate-only [--only 01,02] [--out directory] [--url URL]\n"
    unless $live || $generate;
die "--batch must be 1, 2, 3, 4 or 5\n" unless $batch >= 1 && $batch <= 5;
my $root = abs_path("$Bin/..");
chdir $root or die $!;
$out ||= tempdir('SAS_Output_real30_XXXXXX', DIR => $root, CLEANUP => 0);
make_path($out);
$out = abs_path($out);
my $json = JSON::PP->new->canonical->pretty;
sub save {
    my ($path, $text) = @_;
    open my $fh, '>:raw', $path or die "$path: $!";
    print {$fh} $text;
    close $fh or die $!;
}
sub load_text {
    open my $fh, '<:raw', $_[0] or die "$_[0]: $!";
    local $/; return <$fh>;
}
sub example_fingerprint {
    my ($source)=@_;
    # Reject copies changed only by generated IDs or whitespace.
    $source =~ s/\be\d+/eCASE/ig;
    $source =~ s/MCP30_(OK|ASSERT)_\d+/MCP30_${1}_CASE/g;
    $source =~ s/\s+/ /g;
    return sha256_hex($source);
}
my @cases;
sub example {
    my ($id, $name, $description, $sas, %extra) = @_;
    push @cases, {id => $id, name => $name, description => $description,
        sas => $sas, %extra};
}
example('01', 'sql_join_cardinality', 'Many-to-one join and aggregation: 3 rows, total 80.', <<'SAS');
data e01sales; input key units; datalines;
1 2
1 3
2 1
;
data e01price; input key price; datalines;
1 10
2 30
;
proc sql noprint;
select count(*),sum(a.units*b.price) into :e01n,:e01total
from e01sales a inner join e01price b on a.key=b.key;
quit;
data _null_; if &e01n=3 and &e01total=80 then put 'MCP30_OK_01';
else put 'ERROR: MCP30_ASSERT_01'; run;
proc print data=e01sales; run;
SAS
example('02', 'transpose_duplicate_id', 'Duplicate ID values must fail PROC TRANSPOSE.', <<'SAS', fail => 1, diagnostic => 'occurs twice|duplicate');
data e02; input subject visit value; datalines;
1 1 10
1 1 20
;
proc transpose data=e02 out=e02wide; by subject; id visit; var value; run;
SAS
example('03', 'transpose_after_aggregation', 'Aggregate duplicate visits before transposing: 15 and 30.', <<'SAS');
data e03; input subject visit value; datalines;
1 1 10
1 1 20
1 2 30
;
proc summary data=e03 nway; class subject visit; var value;
output out=e03mean mean=value; run;
proc transpose data=e03mean out=e03wide prefix=v; by subject; id visit; var value; run;
data _null_; set e03wide; if v1=15 and v2=30 then put 'MCP30_OK_03';
else put 'ERROR: MCP30_ASSERT_03'; run;
proc print data=e03wide; run;
SAS
example('04', 'invalid_numeric_input', 'Invalid numeric text creates a missing value and a data-quality NOTE.', <<'SAS', diagnostic => 'Invalid data', quality => 1);
data e04; input id amount; datalines;
1 12
2 bad
3 8
;
proc sql noprint; select sum(amount),sum(missing(amount)) into :e04sum,:e04missing from e04; quit;
data _null_; if &e04sum=20 and &e04missing=1 then put 'MCP30_OK_04';
else put 'ERROR: MCP30_ASSERT_04'; run;
proc print data=e04; run;
SAS
example('05', 'unsorted_by_group', 'A DATA step BY group on unsorted data must fail.', <<'SAS', fail => 1, diagnostic => 'not properly sorted');
data e05; input id amount; datalines;
2 20
1 10
;
data e05out; set e05; by id; if first.id; run;
SAS
example('06', 'missing_custom_format', 'A missing user-defined format must fail with FMTERR.', <<'SAS', fail => 1, diagnostic => 'format.*MCP30MISSING|MCP30MISSING.*format');
options fmterr;
data e06; value=1; format value mcp30missing.; run;
proc print data=e06; run;
SAS
example('07', 'custom_format_mapping', 'Custom age-band format resolves two categories.', <<'SAS');
proc format; value e07band low-<18='minor' 18-high='adult'; run;
data e07; age=17; label=put(age,e07band.); output;
age=21; label=put(age,e07band.); output; run;
data _null_; set e07 end=last; retain good 0;
good+(age=17 and label='minor') or (age=21 and label='adult');
if last then do; if good=2 then put 'MCP30_OK_07'; else put 'ERROR: MCP30_ASSERT_07'; end; run;
proc print data=e07; run;
SAS
example('08', 'json_array_import', 'JSON engine imports a locally generated array: 2 rows, sum 24.', <<'SAS');
filename e08json temp;
data _null_; file e08json; put '{"data":[{"id":1,"value":7},{"id":2,"value":17}]}'; run;
libname e08json json fileref=e08json;
proc sql noprint; select count(*),sum(value) into :e08n,:e08sum from e08json.data; quit;
data _null_; if &e08n=2 and &e08sum=24 then put 'MCP30_OK_08'; else put 'ERROR: MCP30_ASSERT_08'; run;
proc print data=e08json.data; run;
libname e08json clear; filename e08json clear;
SAS
example('09', 'quoted_csv_import', 'DSD preserves commas and doubled quotes in CSV fields.', <<'SAS');
filename e09csv temp;
data _null_; file e09csv; put 'id,label,value'; put '1,"alpha,beta",3'; put '2,"say ""hello""",4'; run;
data e09; infile e09csv dsd firstobs=2 truncover; length label $40; input id label :$40. value; run;
data _null_; set e09 end=last; retain good 0;
good+(id=1 and label='alpha,beta') or (id=2 and label='say "hello"');
if last then do; if good=2 then put 'MCP30_OK_09'; else put 'ERROR: MCP30_ASSERT_09'; end; run;
proc print data=e09; run; filename e09csv clear;
SAS
example('10', 'gzip_write_read', 'ZIP GZIP fileref writes and reads a compressed table: sum 42.', <<'SAS');
filename e10gz zip "%sysfunc(pathname(work))/mcp30_e10.csv.gz" gzip;
data _null_; file e10gz; put '1,11'; put '2,31'; run;
data e10; infile e10gz dsd; input id value; run;
proc sql noprint; select sum(value) into :e10sum from e10; quit;
data _null_; if &e10sum=42 then put 'MCP30_OK_10'; else put 'ERROR: MCP30_ASSERT_10'; run;
proc print data=e10; run; filename e10gz clear;
SAS
example('11', 'quoted_macro_literal', 'Single-quoted literal percent calls must remain ordinary data.', <<'SAS');
data e11; length text $100; text='%mcp30_literal_not_a_macro(unclosed'; run;
data _null_; set e11; if index(text,'literal_not_a_macro') then put 'MCP30_OK_11';
else put 'ERROR: MCP30_ASSERT_11'; run;
proc print data=e11; run;
SAS
example('12', 'macro_local_scope', 'A local macro variable must not change a global variable.', <<'SAS');
%let e12scope=outside;
%macro e12scope_test;
%local e12scope;
%let e12scope=inside;
data e12; length scope $20; scope="&e12scope"; run;
%mend;
%e12scope_test;
data _null_; set e12; if scope='inside' and "&e12scope"='outside' then put 'MCP30_OK_12';
else put 'ERROR: MCP30_ASSERT_12'; run;
proc print data=e12; run;
SAS
example('13', 'hash_missing_key', 'Hash lookup distinguishes a matched key from a missing key.', <<'SAS');
data e13lookup; id=1; value=99; run;
data e13;
if _n_=1 then do;
 if 0 then set e13lookup;
 declare hash h(dataset:'e13lookup'); h.definekey('id'); h.definedata('value'); h.definedone();
end;
do id=1 to 2; call missing(value); rc=h.find(); output; end;
stop; run;
data _null_; set e13 end=last; retain good 0;
good+(id=1 and value=99 and rc=0) or (id=2 and missing(value) and rc ne 0);
if last then do; if good=2 then put 'MCP30_OK_13'; else put 'ERROR: MCP30_ASSERT_13'; end; run;
proc print data=e13; run;
SAS
example('14', 'left_join_unmatched', 'Left join retains an unmatched row as missing.', <<'SAS');
data e14a; do id=1 to 3; output; end; run;
data e14b; id=2; value=40; run;
proc sql; create table e14 as select a.id,b.value from e14a a left join e14b b on a.id=b.id; quit;
proc sql noprint; select count(*),sum(missing(value)) into :e14n,:e14missing from e14; quit;
data _null_; if &e14n=3 and &e14missing=2 then put 'MCP30_OK_14'; else put 'ERROR: MCP30_ASSERT_14'; run;
proc print data=e14; run;
SAS
example('15', 'summary_missing_class', 'MISSING class option retains the unclassified observation.', <<'SAS');
data e15; input group value; datalines;
1 10
1 20
. 7
;
proc summary data=e15 nway missing; class group; var value; output out=e15sum sum=total; run;
proc sql noprint; select count(*),sum(total) into :e15n,:e15sum from e15sum; quit;
data _null_; if &e15n=2 and &e15sum=37 then put 'MCP30_OK_15'; else put 'ERROR: MCP30_ASSERT_15'; run;
proc print data=e15sum; run;
SAS
example('16', 'weighted_frequency', 'PROC FREQ weights yield counts 3 and 7.', <<'SAS');
data e16; input category $ count; datalines;
A 3
B 7
;
proc freq data=e16; tables category / out=e16freq; weight count; run;
data _null_; set e16freq end=last; retain total 0; total+count;
if last then do; if total=10 then put 'MCP30_OK_16'; else put 'ERROR: MCP30_ASSERT_16'; end; run;
SAS
example('17', 'regression_parameter_capture', 'ODS captures the exact slope 3 from PROC REG.', <<'SAS');
data e17; do x=1 to 8; y=2+3*x; output; end; run;
ods output ParameterEstimates=e17params;
proc reg data=e17; model y=x; quit;
data _null_; set e17params; if variable='x' then do;
if abs(estimate-3)<1e-8 then put 'MCP30_OK_17'; else put 'ERROR: MCP30_ASSERT_17'; end; run;
SAS
example('18', 'binomial_logistic_model', 'Grouped binomial logistic regression emits two finite parameters.', <<'SAS');
data e18; input x events total; datalines;
0 2 10
1 4 10
2 6 10
3 8 10
;
ods output ParameterEstimates=e18params;
proc logistic data=e18; model events/total=x; run;
proc sql noprint; select count(*),sum(missing(estimate)) into :e18n,:e18missing from e18params; quit;
data _null_; if &e18n=2 and &e18missing=0 then put 'MCP30_OK_18'; else put 'ERROR: MCP30_ASSERT_18'; run;
SAS
example('19', 'rank_tie_handling', 'TIES=MEAN ranks duplicate minima as 1.5.', <<'SAS');
data e19; input value; datalines;
10
10
20
30
;
proc rank data=e19 out=e19rank ties=mean; var value; ranks rank; run;
data _null_; set e19rank end=last; retain good 0; good+(value=10 and rank=1.5);
if last then do; if good=2 then put 'MCP30_OK_19'; else put 'ERROR: MCP30_ASSERT_19'; end; run;
proc print data=e19rank; run;
SAS
example('20', 'compare_detects_difference', 'PROC COMPARE SYSINFO signals a known numeric difference.', <<'SAS');
data e20a; id=1; value=10; run;
data e20b; id=1; value=11; run;
proc compare base=e20a compare=e20b criterion=0; id id; run;
%let e20info=&sysinfo;
data _null_; if &e20info>0 then put 'MCP30_OK_20'; else put 'ERROR: MCP30_ASSERT_20'; run;
SAS
example('21', 'log_only_success', 'ODS-excluded calculation succeeds with a log and no required HTML.', <<'SAS', html => 0);
ods exclude all;
data e21; do value=1 to 4; output; end; run;
proc sql noprint; select sum(value) into :e21sum from e21; quit;
data _null_; if &e21sum=10 then put 'MCP30_OK_21'; else put 'ERROR: MCP30_ASSERT_21'; run;
ods select all;
SAS
example('22', 'sgplot_two_series', 'Graphics destination renders a generated two-series plot.', <<'SAS');
data e22; do x=1 to 6; measured=x*x; fitted=2*x; output; end; run;
proc sgplot data=e22; series x=x y=measured; series x=x y=fitted; xaxis label='Generated x'; run;
data _null_; put 'MCP30_OK_22'; run;
SAS
example('23', 'report_computed_column', 'PROC REPORT renders a computed net column.', <<'SAS');
data e23; input gross discount; datalines;
100 10
80 20
;
proc report data=e23 nowd; column gross discount net;
define gross / display; define discount / display; define net / computed;
compute net; net=gross-discount; endcomp; run;
data _null_; put 'MCP30_OK_23'; run;
SAS
example('24', 'utf8_csv_roundtrip', 'UTF-8 CSV export/import preserves non-ASCII labels.', <<'SAS');
filename e24csv temp encoding='utf-8';
data e24; length label $40; id=1; label='caf'||'C3A9'x; output;
id=2; label='na'||'C3AF'x||'ve'; output; run;
proc export data=e24 outfile=e24csv dbms=csv replace; run;
proc import datafile=e24csv out=e24back dbms=csv replace; guessingrows=max; run;
proc sql noprint;
select count(*) into :e24matches from e24 a inner join e24back b
on a.id=b.id and a.label=b.label;
quit;
data _null_; if &e24matches=2 then put 'MCP30_OK_24'; else put 'ERROR: MCP30_ASSERT_24'; run;
proc print data=e24back; run;
filename e24csv clear;
SAS
example('25', 'incomplete_assignment', 'An incomplete numeric assignment must fail with a syntax diagnostic.', <<'SAS', fail => 1, diagnostic => 'ERROR\s+(?:22|180|76|388|200)-');
data e25; value=; run;
SAS
example('26', 'abort_cancel', 'Explicit ABORT CANCEL is reported as failure in an isolated session.', <<'SAS', fail => 1, persistent => 0, diagnostic => 'abort|cancel');
data _null_; abort cancel; run;
SAS
example('27', 'unique_index_violation', 'A unique index on duplicated values must fail.', <<'SAS', fail => 1, diagnostic => 'unique|duplicate');
data e27; id=1; value=10; output; value=20; output; run;
proc sql; create unique index id on e27(id); quit;
SAS
example('28', 'append_type_conflict', 'FORCE appends a row but replaces a conflicting numeric value with missing.', <<'SAS', diagnostic => 'WARNING', warning => 1);
data e28base; id=1; value=10; run;
data e28incoming; length value $8; id=2; value='twenty'; run;
proc append base=e28base data=e28incoming force; run;
data _null_; set e28base end=last; if last then do;
if id=2 and missing(value) then put 'MCP30_OK_28'; else put 'ERROR: MCP30_ASSERT_28'; end; run;
proc print data=e28base; run;
SAS
example('29', 'macro_after_statement', 'A valid macro definition can begin after another statement on the same line.', <<'SAS');
options mprint; %macro e29inline;
data e29; value=29; run;
%mend;
%e29inline;
data _null_; set e29; if value=29 then put 'MCP30_OK_29'; else put 'ERROR: MCP30_ASSERT_29'; run;
proc print data=e29; run;
SAS
example('30', 'division_by_zero_note', 'Division by zero is a data-quality NOTE and produces missing, not a fatal SAS error.', <<'SAS', diagnostic => 'Division by zero', quality => 1);
data e30; numerator=10; denominator=0; ratio=numerator/denominator; run;
data _null_; set e30; if missing(ratio) then put 'MCP30_OK_30'; else put 'ERROR: MCP30_ASSERT_30'; run;
proc print data=e30; run;
SAS
if ($batch >= 2) {
    my %previous = map { example_fingerprint($_->{sas}) => 1 } @cases;
    for my $number (2 .. $batch) {
        my $filename = {2=>'new_examples_31_60.pl',3=>'new_examples_61_90.pl',4=>'new_examples_91_190.pl',5=>'new_examples_191_290.pl'}->{$number};
        my $additional = do "$Bin/$filename";
        die "Cannot load batch $number: ".($@ || $! || 'invalid catalog')."\n" unless ref($additional) eq 'ARRAY';
        die "Batch $number repeats a previous source after ID normalization\n" if grep { $previous{example_fingerprint($_->{sas})} } @$additional;
        $previous{example_fingerprint($_->{sas})} = 1 for @$additional;
        @cases = @$additional;
    }
}
my $expected_count=$batch>=4 ? 100 : 30;
die "Expected exactly $expected_count unique examples; got ".scalar(@cases)."\n" unless @cases==$expected_count;
my $source_manifest = -f "$Bin/sas_library_source_manifest.json"
    ? decode_json(load_text("$Bin/sas_library_source_manifest.json")) : {};
my %seen;
my %source_seen;
for my $case (@cases) {
    die "Duplicate example ID\n" if $seen{$case->{id}}++;
    die "Duplicate example source after ID normalization\n" if $source_seen{example_fingerprint($case->{sas})}++;
    if ($case->{source_ref}) {
        die "Missing source provenance: $case->{source_ref}\n"
            unless exists $source_manifest->{$case->{source_ref}};
        my ($collection,$filename)=split /:/,$case->{source_ref},2;
        die "Unknown source collection: $collection\n" unless $collection =~ /\A[ED]\z/;
        $collection=$collection eq 'E' ? 'Easy-For-Error-Codes-SAS' : 'SAS_Code_Database';
        $case->{source_collection}=$collection;
        $case->{source_file}=$filename;
        $case->{source_sha256}=$source_manifest->{$case->{source_ref}}{sha256}
            if exists $source_manifest->{$case->{source_ref}};
        if (length $library_root) {
            my $path="$library_root/$collection/$filename";
            my $hash=sha256_hex(load_text($path));
            die "Library source changed: $path\n" if $case->{source_sha256} && $case->{source_sha256} ne $hash;
            $case->{source_sha256}=$hash;
        }
    }
    $case->{path} = "$out/$case->{id}_$case->{name}.sas";
    save($case->{path}, "options notes nosyntaxcheck obs=max; ods select all; title; footnote;\n".$case->{sas});
}
save("$out/catalog.json", $json->encode(\@cases));
print "Generated $expected_count distinct cases (batch $batch) in $out\n";
exit 0 if $generate && !$live;
my %selected = map { sprintf('%02d', $_) => 1 } split /,/, $only;
die "Unknown --only ID\n" if grep { !exists $seen{$_} } keys %selected;
my $ua = Mojo::UserAgent->new;
$ua->request_timeout(240); $ua->inactivity_timeout(240);
my $rpc_id = 0;
sub call_tool {
    my ($arguments) = @_;
    my $tx = $ua->post($url => {Connection=>'close'} => json => {
        jsonrpc=>'2.0', id=>++$rpc_id, method=>'tools/call',
        params=>{name=>'run_sas_codes_or_files_in_ODA', arguments=>$arguments},
    });
    my $res = $tx->result;
    die "HTTP failure: ".($res->code//'no response')."\n" unless $res->is_success;
    my $body = $res->json;
    die encode_json($body)."\n" unless $body && !$body->{error};
    return $body->{result};
}
my $session = 'mcp30_'.time.'_'.$$;
my @results;
for my $case (@cases) {
    next if %selected && !$selected{$case->{id}};
    my $case_started = time;
    my $result = {id=>$case->{id}, name=>$case->{name}, expected_failure=>$case->{fail}?1:0};
    eval {
        my $started = call_tool({sas_codes_or_file=>$case->{path},
            persistent=>exists($case->{persistent}) && !$case->{persistent} ? JSON::PP::false : JSON::PP::true,
            session_id=>$session, run_timeout_seconds=>180});
        save("$out/$case->{id}_started.json", $json->encode($started));
        my $message = join("\n", map { $_->{text}//'' } @{$started->{content}||[]});
        my ($pid) = $message =~ /PID: (\d+)/;
        my ($directory) = $message =~ /Results directory: ([^\r\n]+)/;
        die "Failed to start: $message\n" unless $pid && $directory;
        $result->{directory}=$directory;
        my $deadline = time+300;
        my $finished;
        while (time<$deadline) {
            sleep(time-$case_started<30 ? 2 : 30);
            $finished=call_tool({pid=>0+$pid});
            $message=join("\n", map { $_->{text}//'' } @{$finished->{content}||[]});
            last unless $message =~ /STATUS: RUNNING/;
        }
        save("$out/$case->{id}_response.json", $json->encode($finished));
        my ($status) = $message =~ /STATUS: (\w+)/;
        my ($exit) = $message =~ /Exit code: (\d+)/;
        $result->{status}=$status//''; $result->{exit}=defined($exit)?0+$exit:undef;
        $result->{isError}=$finished->{isError}?1:0;
        my @problems;
        my $expected=$case->{fail}?'FAILED':'COMPLETE';
        $result->{diagnostics}=$finished->{structuredContent}{diagnostics};
        push @problems,'unexpected data-quality diagnostic'
            if $batch>=5 && !$case->{fail} && !$case->{quality} && ($result->{diagnostics}{data_quality_count}//0);
        push @problems,'unexpected warning'
            if $batch>=5 && !$case->{fail} && !$case->{warning} && ($result->{diagnostics}{warning_count}//0);
        push @problems,'structured status missing/inconsistent'
            unless ($finished->{structuredContent}{status}//'') eq $expected;
        push @problems,'structured data-quality diagnostic absent'
            if $case->{quality} && !($result->{diagnostics}{data_quality_count}//0);
        push @problems,'structured warning absent'
            if $case->{warning} && !($result->{diagnostics}{warning_count}//0);
        push @problems,"status expected $expected, got ".($status//'unknown') unless ($status//'') eq $expected;
        push @problems,'wrong MCP isError flag' unless !!$finished->{isError}==!!$case->{fail};
        push @problems,'wrong/missing exit code' unless defined($exit) && (!!$exit==!!$case->{fail});
        my $log_path="$directory/output.html.info.txt";
        my $log=-f $log_path ? load_text($log_path) : '';
        push @problems,'full log missing' unless length $log;
        push @problems,'expected diagnostic absent' if $case->{diagnostic} && $log !~ /$case->{diagnostic}/i;
        push @problems,'unexpected dependency injection' if $case->{forbid} && $log =~ /$case->{forbid}/i;
        push @problems,'computed result marker absent' if !$case->{fail} && $log !~ /^MCP30_OK_$case->{id}\s*$/m;
        my @html=glob("$directory/sas_res_*.html");
        $result->{html}=[map { +{path=>$_,bytes=>-s $_} } @html];
        push @problems,'nonempty HTML missing' if !$case->{fail} && (!exists($case->{html}) || $case->{html}) && !grep { -s $_ } @html;
        push @problems,'completion markers were not cleaned' if -e "$directory/worker.result.json" || -e "$directory/output.html.info.pid";
        $result->{problems}=\@problems;
        $result->{passed}=@problems?0:1;
        1;
    } or do { $result->{passed}=0; $result->{problems}=[$@||'unknown exception']; };
    $result->{elapsed_seconds}=time-$case_started;
    push @results,$result;
    save("$out/results.json", $json->encode(\@results));
    print "$case->{id} $case->{name}: ".($result->{passed}?'PASS':'FAIL')." (${\($result->{elapsed_seconds})}s)\n";
    print "  $_\n" for @{$result->{problems}||[]};
    $|=1;
}
my $passed=grep { $_->{passed} } @results;
print "RESULT: $passed/".scalar(@results)." cases passed. Artifacts: $out\n";
exit($passed==@results ? 0 : 1);
