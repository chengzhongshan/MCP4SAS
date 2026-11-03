/* R938 cards4_literal_source, N=9; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r938a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_9.sas'; /*
plain_9
;;;;
run;
proc sql; create table r938o as select sum(lengthn(text)) as actual from r938a; quit;

data _null_; if 0 then set r938o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R938 rows=' rows;
else do; set r938o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R938';
else put 'ERROR: ROUND2_FAIL=R938 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r938:; quit;
