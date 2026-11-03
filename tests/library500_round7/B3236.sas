/* B3236 genmod_poisson_intercept, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3236a; do j=1 to 7; count=7; output; end; run;
proc genmod data=b3236a; model count= / dist=poisson link=log; output out=b3236b pred=prediction; run;
proc sql; create table b3236o as select mean(prediction) as actual from b3236b; quit;

data _null_; if 0 then set b3236o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3236 rows=' rows;
else do; set b3236o; if not missing(actual) and abs(actual-(7))<=1e-6*max(1,abs(7)) then put 'ROUND7_PASS=B3236';
else put 'ERROR: ROUND7_FAIL=B3236 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3236:; quit;
