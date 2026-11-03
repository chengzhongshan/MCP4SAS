/* B3240 genmod_poisson_intercept, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3240a; do j=1 to 11; count=11; output; end; run;
proc genmod data=b3240a; model count= / dist=poisson link=log; output out=b3240b pred=prediction; run;
proc sql; create table b3240o as select mean(prediction) as actual from b3240b; quit;

data _null_; if 0 then set b3240o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3240 rows=' rows;
else do; set b3240o; if not missing(actual) and abs(actual-(11))<=1e-6*max(1,abs(11)) then put 'ROUND7_PASS=B3240';
else put 'ERROR: ROUND7_FAIL=B3240 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3240:; quit;
