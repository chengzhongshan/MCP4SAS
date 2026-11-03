/* R932 cards4_literal_source, N=3; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r932a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_3.sas'; /*
plain_3
;;;;
run;
proc sql; create table r932o as select sum(lengthn(text)) as actual from r932a; quit;

data _null_; if 0 then set r932o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R932 rows=' rows;
else do; set r932o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R932';
else put 'ERROR: ROUND2_FAIL=R932 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r932:; quit;
