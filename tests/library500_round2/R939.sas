/* R939 cards4_literal_source, N=10; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r939a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_10.sas'; /*
plain_10
;;;;
run;
proc sql; create table r939o as select sum(lengthn(text)) as actual from r939a; quit;

data _null_; if 0 then set r939o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R939 rows=' rows;
else do; set r939o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R939';
else put 'ERROR: ROUND2_FAIL=R939 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r939:; quit;
