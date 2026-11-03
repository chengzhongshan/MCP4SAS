/* B3250 genmod_poisson_groups, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3250a; do grp=0 to 1; do j=1 to 3; count=11*(1+grp); output; end; end; run;
proc genmod data=b3250a; model count=grp / dist=poisson link=log; output out=b3250b pred=prediction; run;
proc sql; create table b3250o as select mean(prediction) as actual from b3250b where grp=1; quit;

data _null_; if 0 then set b3250o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3250 rows=' rows;
else do; set b3250o; if not missing(actual) and abs(actual-(22))<=1e-6*max(1,abs(22)) then put 'ROUND7_PASS=B3250';
else put 'ERROR: ROUND7_FAIL=B3250 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3250:; quit;
