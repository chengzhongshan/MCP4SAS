/* B3221 logistic_freq_aggregates, N=2; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3221a; y=0; weight=2; output; y=1; weight=2*2; output; run;
proc logistic data=b3221a noprint; freq weight; model y(event='1')=; output out=b3221b p=prob; run;
proc sql; create table b3221o as select mean(prob) as actual from b3221b; quit;

data _null_; if 0 then set b3221o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3221 rows=' rows;
else do; set b3221o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3221';
else put 'ERROR: ROUND7_FAIL=B3221 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3221:; quit;
