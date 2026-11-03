/* F1890 sql_population_covariance, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1890a; do x=1 to 11; y=3*x; output; end; run;
proc sql; create table f1890o as select mean(x*y)-mean(x)*mean(y) as actual from f1890a; quit;

data _null_; if 0 then set f1890o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1890 rows=' rows;
else do; set f1890o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND4_PASS=F1890';
else put 'ERROR: ROUND4_FAIL=F1890 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1890:; quit;
