/* F1883 sql_population_covariance, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1883a; do x=1 to 4; y=3*x; output; end; run;
proc sql; create table f1883o as select mean(x*y)-mean(x)*mean(y) as actual from f1883a; quit;

data _null_; if 0 then set f1883o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1883 rows=' rows;
else do; set f1883o; if not missing(actual) and abs(actual-(3.75))<=1e-9*max(1,abs(3.75)) then put 'ROUND4_PASS=F1883';
else put 'ERROR: ROUND4_FAIL=F1883 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1883:; quit;
