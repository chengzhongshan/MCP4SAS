/* B3268 genmod_poisson_exposure_offset, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3268a; do exposure=1 to 3; count=9*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3268a; model count= / dist=poisson link=log offset=offset; output out=b3268b pred=prediction; run;
proc sql; create table b3268o as select mean(prediction/exposure) as actual from b3268b; quit;

data _null_; if 0 then set b3268o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3268 rows=' rows;
else do; set b3268o; if not missing(actual) and abs(actual-(9))<=1e-6*max(1,abs(9)) then put 'ROUND7_PASS=B3268';
else put 'ERROR: ROUND7_FAIL=B3268 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3268:; quit;
