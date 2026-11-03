/* F1894 sql_standard_error, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1894a; do x=1 to 5; output; end; run;
proc sql; create table f1894o as select stderr(x) as actual from f1894a; quit;

data _null_; if 0 then set f1894o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1894 rows=' rows;
else do; set f1894o; if not missing(actual) and abs(actual-(0.707106781186548))<=1e-9*max(1,abs(0.707106781186548)) then put 'ROUND4_PASS=F1894';
else put 'ERROR: ROUND4_FAIL=F1894 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1894:; quit;
