/* B3228 logistic_freq_aggregates, N=9; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3228a; y=0; weight=9; output; y=1; weight=2*9; output; run;
proc logistic data=b3228a noprint; freq weight; model y(event='1')=; output out=b3228b p=prob; run;
proc sql; create table b3228o as select mean(prob) as actual from b3228b; quit;

data _null_; if 0 then set b3228o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3228 rows=' rows;
else do; set b3228o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3228';
else put 'ERROR: ROUND7_FAIL=B3228 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3228:; quit;
