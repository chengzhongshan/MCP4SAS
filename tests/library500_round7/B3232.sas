/* B3232 genmod_poisson_intercept, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3232a; do j=1 to 3; count=3; output; end; run;
proc genmod data=b3232a; model count= / dist=poisson link=log; output out=b3232b pred=prediction; run;
proc sql; create table b3232o as select mean(prediction) as actual from b3232b; quit;

data _null_; if 0 then set b3232o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3232 rows=' rows;
else do; set b3232o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND7_PASS=B3232';
else put 'ERROR: ROUND7_FAIL=B3232 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3232:; quit;
