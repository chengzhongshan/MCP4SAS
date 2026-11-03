/* B3239 genmod_poisson_intercept, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3239a; do j=1 to 10; count=10; output; end; run;
proc genmod data=b3239a; model count= / dist=poisson link=log; output out=b3239b pred=prediction; run;
proc sql; create table b3239o as select mean(prediction) as actual from b3239b; quit;

data _null_; if 0 then set b3239o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3239 rows=' rows;
else do; set b3239o; if not missing(actual) and abs(actual-(10))<=1e-6*max(1,abs(10)) then put 'ROUND7_PASS=B3239';
else put 'ERROR: ROUND7_FAIL=B3239 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3239:; quit;
