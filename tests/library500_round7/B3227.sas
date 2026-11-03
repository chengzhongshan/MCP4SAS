/* B3227 logistic_freq_aggregates, N=8; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3227a; y=0; weight=8; output; y=1; weight=2*8; output; run;
proc logistic data=b3227a noprint; freq weight; model y(event='1')=; output out=b3227b p=prob; run;
proc sql; create table b3227o as select mean(prob) as actual from b3227b; quit;

data _null_; if 0 then set b3227o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3227 rows=' rows;
else do; set b3227o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3227';
else put 'ERROR: ROUND7_FAIL=B3227 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3227:; quit;
