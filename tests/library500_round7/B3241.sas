/* B3241 genmod_poisson_groups, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3241a; do grp=0 to 1; do j=1 to 3; count=2*(1+grp); output; end; end; run;
proc genmod data=b3241a; model count=grp / dist=poisson link=log; output out=b3241b pred=prediction; run;
proc sql; create table b3241o as select mean(prediction) as actual from b3241b where grp=1; quit;

data _null_; if 0 then set b3241o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3241 rows=' rows;
else do; set b3241o; if not missing(actual) and abs(actual-(4))<=1e-6*max(1,abs(4)) then put 'ROUND7_PASS=B3241';
else put 'ERROR: ROUND7_FAIL=B3241 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3241:; quit;
