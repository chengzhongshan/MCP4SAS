/* B3243 genmod_poisson_groups, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3243a; do grp=0 to 1; do j=1 to 3; count=4*(1+grp); output; end; end; run;
proc genmod data=b3243a; model count=grp / dist=poisson link=log; output out=b3243b pred=prediction; run;
proc sql; create table b3243o as select mean(prediction) as actual from b3243b where grp=1; quit;

data _null_; if 0 then set b3243o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3243 rows=' rows;
else do; set b3243o; if not missing(actual) and abs(actual-(8))<=1e-6*max(1,abs(8)) then put 'ROUND7_PASS=B3243';
else put 'ERROR: ROUND7_FAIL=B3243 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3243:; quit;
