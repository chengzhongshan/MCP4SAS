/* B3252 genmod_binomial_trials, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3252a; do j=1 to 3; events=3; trials=3*3; output; end; run;
proc genmod data=b3252a; model events/trials= / dist=binomial link=logit; output out=b3252b pred=prediction; run;
proc sql; create table b3252o as select mean(prediction) as actual from b3252b; quit;

data _null_; if 0 then set b3252o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3252 rows=' rows;
else do; set b3252o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-6*max(1,abs(0.333333333333333)) then put 'ROUND7_PASS=B3252';
else put 'ERROR: ROUND7_FAIL=B3252 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3252:; quit;
