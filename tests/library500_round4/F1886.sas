/* F1886 sql_population_covariance, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1886a; do x=1 to 7; y=3*x; output; end; run;
proc sql; create table f1886o as select mean(x*y)-mean(x)*mean(y) as actual from f1886a; quit;

data _null_; if 0 then set f1886o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1886 rows=' rows;
else do; set f1886o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1886';
else put 'ERROR: ROUND4_FAIL=F1886 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1886:; quit;
