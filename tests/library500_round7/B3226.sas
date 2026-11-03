/* B3226 logistic_freq_aggregates, N=7; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3226a; y=0; weight=7; output; y=1; weight=2*7; output; run;
proc logistic data=b3226a noprint; freq weight; model y(event='1')=; output out=b3226b p=prob; run;
proc sql; create table b3226o as select mean(prob) as actual from b3226b; quit;

data _null_; if 0 then set b3226o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3226 rows=' rows;
else do; set b3226o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3226';
else put 'ERROR: ROUND7_FAIL=B3226 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3226:; quit;
