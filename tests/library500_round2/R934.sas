/* R934 cards4_literal_source, N=5; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:548 */

data r934a; infile datalines4 truncover; input text $char100.; datalines4;
%include 'absent_5.sas'; /*
plain_5
;;;;
run;
proc sql; create table r934o as select sum(lengthn(text)) as actual from r934a; quit;

data _null_; if 0 then set r934o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R934 rows=' rows;
else do; set r934o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND2_PASS=R934';
else put 'ERROR: ROUND2_FAIL=R934 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r934:; quit;
