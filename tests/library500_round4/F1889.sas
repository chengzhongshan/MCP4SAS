/* F1889 sql_population_covariance, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1889a; do x=1 to 10; y=3*x; output; end; run;
proc sql; create table f1889o as select mean(x*y)-mean(x)*mean(y) as actual from f1889a; quit;

data _null_; if 0 then set f1889o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1889 rows=' rows;
else do; set f1889o; if not missing(actual) and abs(actual-(24.75))<=1e-9*max(1,abs(24.75)) then put 'ROUND4_PASS=F1889';
else put 'ERROR: ROUND4_FAIL=F1889 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1889:; quit;
