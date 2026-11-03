/* B3223 logistic_freq_aggregates, N=4; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3223a; y=0; weight=4; output; y=1; weight=2*4; output; run;
proc logistic data=b3223a noprint; freq weight; model y(event='1')=; output out=b3223b p=prob; run;
proc sql; create table b3223o as select mean(prob) as actual from b3223b; quit;

data _null_; if 0 then set b3223o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3223 rows=' rows;
else do; set b3223o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3223';
else put 'ERROR: ROUND7_FAIL=B3223 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3223:; quit;
