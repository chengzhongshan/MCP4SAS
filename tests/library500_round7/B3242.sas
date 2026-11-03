/* B3242 genmod_poisson_groups, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3242a; do grp=0 to 1; do j=1 to 3; count=3*(1+grp); output; end; end; run;
proc genmod data=b3242a; model count=grp / dist=poisson link=log; output out=b3242b pred=prediction; run;
proc sql; create table b3242o as select mean(prediction) as actual from b3242b where grp=1; quit;

data _null_; if 0 then set b3242o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3242 rows=' rows;
else do; set b3242o; if not missing(actual) and abs(actual-(6))<=1e-6*max(1,abs(6)) then put 'ROUND7_PASS=B3242';
else put 'ERROR: ROUND7_FAIL=B3242 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3242:; quit;
