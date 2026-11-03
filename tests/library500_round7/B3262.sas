/* B3262 genmod_poisson_exposure_offset, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3262a; do exposure=1 to 3; count=3*exposure; offset=log(exposure); output; end; run;
proc genmod data=b3262a; model count= / dist=poisson link=log offset=offset; output out=b3262b pred=prediction; run;
proc sql; create table b3262o as select mean(prediction/exposure) as actual from b3262b; quit;

data _null_; if 0 then set b3262o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3262 rows=' rows;
else do; set b3262o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND7_PASS=B3262';
else put 'ERROR: ROUND7_FAIL=B3262 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3262:; quit;
