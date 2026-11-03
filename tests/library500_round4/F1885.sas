/* F1885 sql_population_covariance, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1885a; do x=1 to 6; y=3*x; output; end; run;
proc sql; create table f1885o as select mean(x*y)-mean(x)*mean(y) as actual from f1885a; quit;

data _null_; if 0 then set f1885o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1885 rows=' rows;
else do; set f1885o; if not missing(actual) and abs(actual-(8.75))<=1e-9*max(1,abs(8.75)) then put 'ROUND4_PASS=F1885';
else put 'ERROR: ROUND4_FAIL=F1885 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1885:; quit;
