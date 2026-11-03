/* B3267 genmod_poisson_exposure_offset, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3267a; do exposure=1 to 3; count=8*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3267a; model count= / dist=poisson link=log offset=offset; output out=b3267b pred=prediction; run;
proc sql; create table b3267o as select mean(prediction/exposure) as actual from b3267b; quit;

data _null_; if 0 then set b3267o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3267 rows=' rows;
else do; set b3267o; if not missing(actual) and abs(actual-(8))<=1e-6*max(1,abs(8)) then put 'ROUND7_PASS=B3267';
else put 'ERROR: ROUND7_FAIL=B3267 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3267:; quit;
