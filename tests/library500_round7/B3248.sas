/* B3248 genmod_poisson_groups, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3248a; do grp=0 to 1; do j=1 to 3; count=9*(1+grp); output; end; end; run;
proc genmod data=b3248a; model count=grp / dist=poisson link=log; output out=b3248b pred=prediction; run;
proc sql; create table b3248o as select mean(prediction) as actual from b3248b where grp=1; quit;

data _null_; if 0 then set b3248o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3248 rows=' rows;
else do; set b3248o; if not missing(actual) and abs(actual-(18))<=1e-6*max(1,abs(18)) then put 'ROUND7_PASS=B3248';
else put 'ERROR: ROUND7_FAIL=B3248 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3248:; quit;
