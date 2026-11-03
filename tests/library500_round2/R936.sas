/* R936 cards4_literal_source, N=7; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r936a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_7.sas'; /*
plain_7
;;;;
run;
proc sql; create table r936o as select sum(lengthn(text)) as actual from r936a; quit;

data _null_; if 0 then set r936o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R936 rows=' rows;
else do; set r936o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R936';
else put 'ERROR: ROUND2_FAIL=R936 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r936:; quit;
