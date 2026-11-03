/* R937 cards4_literal_source, N=8; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r937a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_8.sas'; /*
plain_8
;;;;
run;
proc sql; create table r937o as select sum(lengthn(text)) as actual from r937a; quit;

data _null_; if 0 then set r937o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R937 rows=' rows;
else do; set r937o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R937';
else put 'ERROR: ROUND2_FAIL=R937 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r937:; quit;
