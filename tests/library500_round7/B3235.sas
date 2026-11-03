/* B3235 genmod_poisson_intercept, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3235a; do j=1 to 6; count=6; output; end; run;
proc genmod data=b3235a; model count= / dist=poisson link=log; output out=b3235b pred=prediction; run;
proc sql; create table b3235o as select mean(prediction) as actual from b3235b; quit;

data _null_; if 0 then set b3235o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3235 rows=' rows;
else do; set b3235o; if not missing(actual) and abs(actual-(6))<=1e-6*max(1,abs(6)) then put 'ROUND7_PASS=B3235';
else put 'ERROR: ROUND7_FAIL=B3235 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3235:; quit;
