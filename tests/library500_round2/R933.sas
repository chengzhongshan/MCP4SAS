/* R933 cards4_literal_source, N=4; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r933a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_4.sas'; /*
plain_4
;;;;
run;
proc sql; create table r933o as select sum(lengthn(text)) as actual from r933a; quit;

data _null_; if 0 then set r933o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R933 rows=' rows;
else do; set r933o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R933';
else put 'ERROR: ROUND2_FAIL=R933 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r933:; quit;
