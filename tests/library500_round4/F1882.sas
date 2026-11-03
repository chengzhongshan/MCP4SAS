/* F1882 sql_population_covariance, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1882a; do x=1 to 3; y=3*x; output; end; run;
proc sql; create table f1882o as select mean(x*y)-mean(x)*mean(y) as actual from f1882a; quit;

data _null_; if 0 then set f1882o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1882 rows=' rows;
else do; set f1882o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1882';
else put 'ERROR: ROUND4_FAIL=F1882 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1882:; quit;
