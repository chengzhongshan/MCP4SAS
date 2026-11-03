/* R935 cards4_literal_source, N=6; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r935a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_6.sas'; /*
plain_6
;;;;
run;
proc sql; create table r935o as select sum(lengthn(text)) as actual from r935a; quit;

data _null_; if 0 then set r935o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R935 rows=' rows;
else do; set r935o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R935';
else put 'ERROR: ROUND2_FAIL=R935 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r935:; quit;
