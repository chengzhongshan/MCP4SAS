/* B3270 genmod_poisson_exposure_offset, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3270a; do exposure=1 to 3; count=11*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3270a; model count= / dist=poisson link=log offset=offset; output out=b3270b pred=prediction; run;
proc sql; create table b3270o as select mean(prediction/exposure) as actual from b3270b; quit;

data _null_; if 0 then set b3270o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3270 rows=' rows;
else do; set b3270o; if not missing(actual) and abs(actual-(11))<=1e-6*max(1,abs(11)) then put 'ROUND7_PASS=B3270';
else put 'ERROR: ROUND7_FAIL=B3270 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3270:; quit;
