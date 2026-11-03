/* B3251 genmod_binomial_trials, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1058 */

data b3251a; do j=1 to 3; events=2; trials=3*2; output; end; run;
proc genmod data=b3251a; model events/trials= / dist=binomial link=logit; output out=b3251b pred=prediction; run;
proc sql; create table b3251o as select mean(prediction) as actual from b3251b; quit;

data _null_; if 0 then set b3251o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3251 rows=' rows;
else do; set b3251o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-6*max(1,abs(0.333333333333333)) then put 'ROUND7_PASS=B3251';
else put 'ERROR: ROUND7_FAIL=B3251 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3251:; quit;
