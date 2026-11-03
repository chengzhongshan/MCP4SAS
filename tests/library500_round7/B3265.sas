/* B3265 genmod_poisson_exposure_offset, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3265a; do exposure=1 to 3; count=6*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3265a; model count= / dist=poisson link=log offset=offset; output out=b3265b pred=prediction; run;
proc sql; create table b3265o as select mean(prediction/exposure) as actual from b3265b; quit;

data _null_; if 0 then set b3265o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3265 rows=' rows;
else do; set b3265o; if not missing(actual) and abs(actual-(6))<=1e-6*max(1,abs(6)) then put 'ROUND7_PASS=B3265';
else put 'ERROR: ROUND7_FAIL=B3265 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3265:; quit;
