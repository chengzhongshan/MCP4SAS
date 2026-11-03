/* B3222 logistic_freq_aggregates, N=3; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3222a; y=0; weight=3; output; y=1; weight=2*3; output; run;
proc logistic data=b3222a noprint; freq weight; model y(event='1')=; output out=b3222b p=prob; run;
proc sql; create table b3222o as select mean(prob) as actual from b3222b; quit;

data _null_; if 0 then set b3222o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3222 rows=' rows;
else do; set b3222o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3222';
else put 'ERROR: ROUND7_FAIL=B3222 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3222:; quit;
