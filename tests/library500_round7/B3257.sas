/* B3257 genmod_binomial_trials, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3257a; do j=1 to 3; events=8; trials=3*8; output; end; run;
proc genmod data=b3257a; model events/trials= / dist=binomial link=logit; output out=b3257b pred=prediction; run;
proc sql; create table b3257o as select mean(prediction) as actual from b3257b; quit;

data _null_; if 0 then set b3257o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3257 rows=' rows;
else do; set b3257o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-6*max(1,abs(0.333333333333333)) then put 'ROUND7_PASS=B3257';
else put 'ERROR: ROUND7_FAIL=B3257 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3257:; quit;
