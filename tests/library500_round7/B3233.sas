/* B3233 genmod_poisson_intercept, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3233a; do j=1 to 4; count=4; output; end; run;
proc genmod data=b3233a; model count= / dist=poisson link=log; output out=b3233b pred=prediction; run;
proc sql; create table b3233o as select mean(prediction) as actual from b3233b; quit;

data _null_; if 0 then set b3233o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3233 rows=' rows;
else do; set b3233o; if not missing(actual) and abs(actual-(4))<=1e-6*max(1,abs(4)) then put 'ROUND7_PASS=B3233';
else put 'ERROR: ROUND7_FAIL=B3233 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3233:; quit;
