/* F1884 sql_population_covariance, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1884a; do x=1 to 5; y=3*x; output; end; run;
proc sql; create table f1884o as select mean(x*y)-mean(x)*mean(y) as actual from f1884a; quit;

data _null_; if 0 then set f1884o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1884 rows=' rows;
else do; set f1884o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1884';
else put 'ERROR: ROUND4_FAIL=F1884 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1884:; quit;
