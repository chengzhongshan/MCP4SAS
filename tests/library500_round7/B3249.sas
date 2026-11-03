/* B3249 genmod_poisson_groups, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3249a; do grp=0 to 1; do j=1 to 3; count=10*(1+grp); output; end; end; run;
proc genmod data=b3249a; model count=grp / dist=poisson link=log; output out=b3249b pred=prediction; run;
proc sql; create table b3249o as select mean(prediction) as actual from b3249b where grp=1; quit;

data _null_; if 0 then set b3249o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3249 rows=' rows;
else do; set b3249o; if not missing(actual) and abs(actual-(20))<=1e-6*max(1,abs(20)) then put 'ROUND7_PASS=B3249';
else put 'ERROR: ROUND7_FAIL=B3249 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3249:; quit;
