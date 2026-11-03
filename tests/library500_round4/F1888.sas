/* F1888 sql_population_covariance, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1888a; do x=1 to 9; y=3*x; output; end; run;
proc sql; create table f1888o as select mean(x*y)-mean(x)*mean(y) as actual from f1888a; quit;

data _null_; if 0 then set f1888o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1888 rows=' rows;
else do; set f1888o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1888';
else put 'ERROR: ROUND4_FAIL=F1888 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1888:; quit;
