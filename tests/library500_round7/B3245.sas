/* B3245 genmod_poisson_groups, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3245a; do grp=0 to 1; do j=1 to 3; count=6*(1+grp); output; end; end; run;
proc genmod data=b3245a; model count=grp / dist=poisson link=log; output out=b3245b pred=prediction; run;
proc sql; create table b3245o as select mean(prediction) as actual from b3245b where grp=1; quit;

data _null_; if 0 then set b3245o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3245 rows=' rows;
else do; set b3245o; if not missing(actual) and abs(actual-(12))<=1e-6*max(1,abs(12)) then put 'ROUND7_PASS=B3245';
else put 'ERROR: ROUND7_FAIL=B3245 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3245:; quit;
