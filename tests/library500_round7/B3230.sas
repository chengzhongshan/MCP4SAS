/* B3230 logistic_freq_aggregates, N=11; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3230a; y=0; weight=11; output; y=1; weight=2*11; output; run;
proc logistic data=b3230a noprint; freq weight; model y(event='1')=; output out=b3230b p=prob; run;
proc sql; create table b3230o as select mean(prob) as actual from b3230b; quit;

data _null_; if 0 then set b3230o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3230 rows=' rows;
else do; set b3230o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3230';
else put 'ERROR: ROUND7_FAIL=B3230 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3230:; quit;
