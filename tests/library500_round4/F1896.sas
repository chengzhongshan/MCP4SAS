/* F1896 sql_standard_error, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1896a; do x=1 to 7; output; end; run;
proc sql; create table f1896o as select stderr(x) as actual from f1896a; quit;

data _null_; if 0 then set f1896o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1896 rows=' rows;
else do; set f1896o; if not missing(actual) and abs(actual-(0.816496580927726))<=1e-9*max(1,abs(0.816496580927726)) then put 'ROUND4_PASS=F1896';
else put 'ERROR: ROUND4_FAIL=F1896 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1896:; quit;
