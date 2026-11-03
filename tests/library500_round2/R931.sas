/* R931 cards4_literal_source, N=2; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r931a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_2.sas'; /*
plain_2
;;;;
run;
proc sql; create table r931o as select sum(lengthn(text)) as actual from r931a; quit;

data _null_; if 0 then set r931o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R931 rows=' rows;
else do; set r931o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R931';
else put 'ERROR: ROUND2_FAIL=R931 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r931:; quit;
