/* B3224 logistic_freq_aggregates, N=5; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3224a; y=0; weight=5; output; y=1; weight=2*5; output; run;
proc logistic data=b3224a noprint; freq weight; model y(event='1')=; output out=b3224b p=prob; run;
proc sql; create table b3224o as select mean(prob) as actual from b3224b; quit;

data _null_; if 0 then set b3224o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3224 rows=' rows;
else do; set b3224o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3224';
else put 'ERROR: ROUND7_FAIL=B3224 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3224:; quit;
