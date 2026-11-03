/* B3258 genmod_binomial_trials, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3258a; do j=1 to 3; events=9; trials=3*9; output; end; run;
proc genmod data=b3258a; model events/trials= / dist=binomial link=logit; output out=b3258b pred=prediction; run;
proc sql; create table b3258o as select mean(prediction) as actual from b3258b; quit;

data _null_; if 0 then set b3258o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3258 rows=' rows;
else do; set b3258o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-6*max(1,abs(0.333333333333333)) then put 'ROUND7_PASS=B3258';
else put 'ERROR: ROUND7_FAIL=B3258 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3258:; quit;
