/* B3263 genmod_poisson_exposure_offset, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3263a; do exposure=1 to 3; count=4*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3263a; model count= / dist=poisson link=log offset=offset; output out=b3263b pred=prediction; run;
proc sql; create table b3263o as select mean(prediction/exposure) as actual from b3263b; quit;

data _null_; if 0 then set b3263o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3263 rows=' rows;
else do; set b3263o; if not missing(actual) and abs(actual-(4))<=1e-6*max(1,abs(4)) then put 'ROUND7_PASS=B3263';
else put 'ERROR: ROUND7_FAIL=B3263 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3263:; quit;
