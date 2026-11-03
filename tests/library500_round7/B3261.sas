/* B3261 genmod_poisson_exposure_offset, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3261a; do exposure=1 to 3; count=2*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3261a; model count= / dist=poisson link=log offset=offset; output out=b3261b pred=prediction; run;
proc sql; create table b3261o as select mean(prediction/exposure) as actual from b3261b; quit;

data _null_; if 0 then set b3261o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3261 rows=' rows;
else do; set b3261o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND7_PASS=B3261';
else put 'ERROR: ROUND7_FAIL=B3261 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3261:; quit;
