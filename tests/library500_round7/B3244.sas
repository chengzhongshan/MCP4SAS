/* B3244 genmod_poisson_groups, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3244a; do grp=0 to 1; do j=1 to 3; count=5*(1+grp); output; end; end; run;
proc genmod data=b3244a; model count=grp / dist=poisson link=log; output out=b3244b pred=prediction; run;
proc sql; create table b3244o as select mean(prediction) as actual from b3244b where grp=1; quit;

data _null_; if 0 then set b3244o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3244 rows=' rows;
else do; set b3244o; if not missing(actual) and abs(actual-(10))<=1e-6*max(1,abs(10)) then put 'ROUND7_PASS=B3244';
else put 'ERROR: ROUND7_FAIL=B3244 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3244:; quit;
