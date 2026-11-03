/* F1900 sql_standard_error, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1900a; do x=1 to 11; output; end; run;
proc sql; create table f1900o as select stderr(x) as actual from f1900a; quit;

data _null_; if 0 then set f1900o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1900 rows=' rows;
else do; set f1900o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1900';
else put 'ERROR: ROUND4_FAIL=F1900 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1900:; quit;
