/* B3246 genmod_poisson_groups, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3246a; do grp=0 to 1; do j=1 to 3; count=7*(1+grp); output; end; end; run;
proc genmod data=b3246a; model count=grp / dist=poisson link=log; output out=b3246b pred=prediction; run;
proc sql; create table b3246o as select mean(prediction) as actual from b3246b where grp=1; quit;

data _null_; if 0 then set b3246o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3246 rows=' rows;
else do; set b3246o; if not missing(actual) and abs(actual-(14))<=1e-6*max(1,abs(14)) then put 'ROUND7_PASS=B3246';
else put 'ERROR: ROUND7_FAIL=B3246 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3246:; quit;
