/* B3231 genmod_poisson_intercept, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3231a; do j=1 to 2; count=2; output; end; run;
proc genmod data=b3231a; model count= / dist=poisson link=log; output out=b3231b pred=prediction; run;
proc sql; create table b3231o as select mean(prediction) as actual from b3231b; quit;

data _null_; if 0 then set b3231o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3231 rows=' rows;
else do; set b3231o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND7_PASS=B3231';
else put 'ERROR: ROUND7_FAIL=B3231 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3231:; quit;
