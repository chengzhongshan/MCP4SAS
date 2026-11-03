/* R940 cards4_literal_source, N=11; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r940a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_11.sas'; /*
plain_11
;;;;
run;
proc sql; create table r940o as select sum(lengthn(text)) as actual from r940a; quit;

data _null_; if 0 then set r940o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R940 rows=' rows;
else do; set r940o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R940';
else put 'ERROR: ROUND2_FAIL=R940 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r940:; quit;
