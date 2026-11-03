/* B3229 logistic_freq_aggregates, N=10; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3229a; y=0; weight=10; output; y=1; weight=2*10; output; run;
proc logistic data=b3229a noprint; freq weight; model y(event='1')=; output out=b3229b p=prob; run;
proc sql; create table b3229o as select mean(prob) as actual from b3229b; quit;

data _null_; if 0 then set b3229o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3229 rows=' rows;
else do; set b3229o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3229';
else put 'ERROR: ROUND7_FAIL=B3229 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3229:; quit;
