/* B3237 genmod_poisson_intercept, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3237a; do j=1 to 8; count=8; output; end; run;
proc genmod data=b3237a; model count= / dist=poisson link=log; output out=b3237b pred=prediction; run;
proc sql; create table b3237o as select mean(prediction) as actual from b3237b; quit;

data _null_; if 0 then set b3237o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3237 rows=' rows;
else do; set b3237o; if not missing(actual) and abs(actual-(8))<=1e-6*max(1,abs(8)) then put 'ROUND7_PASS=B3237';
else put 'ERROR: ROUND7_FAIL=B3237 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3237:; quit;
