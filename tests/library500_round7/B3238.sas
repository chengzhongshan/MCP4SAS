/* B3238 genmod_poisson_intercept, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3238a; do j=1 to 9; count=9; output; end; run;
proc genmod data=b3238a; model count= / dist=poisson link=log; output out=b3238b pred=prediction; run;
proc sql; create table b3238o as select mean(prediction) as actual from b3238b; quit;

data _null_; if 0 then set b3238o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3238 rows=' rows;
else do; set b3238o; if not missing(actual) and abs(actual-(9))<=1e-6*max(1,abs(9)) then put 'ROUND7_PASS=B3238';
else put 'ERROR: ROUND7_FAIL=B3238 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3238:; quit;
