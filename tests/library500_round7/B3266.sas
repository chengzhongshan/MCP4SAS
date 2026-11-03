/* B3266 genmod_poisson_exposure_offset, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3266a; do exposure=1 to 3; count=7*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3266a; model count= / dist=poisson link=log offset=offset; output out=b3266b pred=prediction; run;
proc sql; create table b3266o as select mean(prediction/exposure) as actual from b3266b; quit;

data _null_; if 0 then set b3266o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3266 rows=' rows;
else do; set b3266o; if not missing(actual) and abs(actual-(7))<=1e-6*max(1,abs(7)) then put 'ROUND7_PASS=B3266';
else put 'ERROR: ROUND7_FAIL=B3266 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3266:; quit;
