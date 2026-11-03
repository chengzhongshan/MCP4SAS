/* B3264 genmod_poisson_exposure_offset, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3264a; do exposure=1 to 3; count=5*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3264a; model count= / dist=poisson link=log offset=offset; output out=b3264b pred=prediction; run;
proc sql; create table b3264o as select mean(prediction/exposure) as actual from b3264b; quit;

data _null_; if 0 then set b3264o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3264 rows=' rows;
else do; set b3264o; if not missing(actual) and abs(actual-(5))<=1e-6*max(1,abs(5)) then put 'ROUND7_PASS=B3264';
else put 'ERROR: ROUND7_FAIL=B3264 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3264:; quit;
