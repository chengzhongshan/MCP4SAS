/* F1881 sql_population_covariance, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1881a; do x=1 to 2; y=3*x; output; end; run;
proc sql; create table f1881o as select mean(x*y)-mean(x)*mean(y) as actual from f1881a; quit;

data _null_; if 0 then set f1881o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1881 rows=' rows;
else do; set f1881o; if not missing(actual) and abs(actual-(0.75))<=1e-9*max(1,abs(0.75)) then put 'ROUND4_PASS=F1881';
else put 'ERROR: ROUND4_FAIL=F1881 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1881:; quit;
