/* B3269 genmod_poisson_exposure_offset, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3269a; do exposure=1 to 3; count=10*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3269a; model count= / dist=poisson link=log offset=offset; output out=b3269b pred=prediction; run;
proc sql; create table b3269o as select mean(prediction/exposure) as actual from b3269b; quit;

data _null_; if 0 then set b3269o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3269 rows=' rows;
else do; set b3269o; if not missing(actual) and abs(actual-(10))<=1e-6*max(1,abs(10)) then put 'ROUND7_PASS=B3269';
else put 'ERROR: ROUND7_FAIL=B3269 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3269:; quit;
