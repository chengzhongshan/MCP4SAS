/* B3234 genmod_poisson_intercept, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3234a; do j=1 to 5; count=5; output; end; run;
proc genmod data=b3234a; model count= / dist=poisson link=log; output out=b3234b pred=prediction; run;
proc sql; create table b3234o as select mean(prediction) as actual from b3234b; quit;

data _null_; if 0 then set b3234o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3234 rows=' rows;
else do; set b3234o; if not missing(actual) and abs(actual-(5))<=1e-6*max(1,abs(5)) then put 'ROUND7_PASS=B3234';
else put 'ERROR: ROUND7_FAIL=B3234 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3234:; quit;
