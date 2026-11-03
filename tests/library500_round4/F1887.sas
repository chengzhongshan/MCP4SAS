/* F1887 sql_population_covariance, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1887a; do x=1 to 8; y=3*x; output; end; run;
proc sql; create table f1887o as select mean(x*y)-mean(x)*mean(y) as actual from f1887a; quit;

data _null_; if 0 then set f1887o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1887 rows=' rows;
else do; set f1887o; if not missing(actual) and abs(actual-(15.75))<=1e-9*max(1,abs(15.75)) then put 'ROUND4_PASS=F1887';
else put 'ERROR: ROUND4_FAIL=F1887 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1887:; quit;
