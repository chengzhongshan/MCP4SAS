/* B3198 logistic_balanced_intercept, N=9; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3198a; do y=0 to 1; do j=1 to 9; output; end; end; run;
proc logistic data=b3198a noprint; model y(event='1')=; output out=b3198b p=prob; run;
proc sql; create table b3198o as select mean(prob) as actual from b3198b; quit;

data _null_; if 0 then set b3198o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3198 rows=' rows;
else do; set b3198o; if not missing(actual) and abs(actual-(0.5))<=1e-6*max(1,abs(0.5)) then put 'ROUND7_PASS=B3198';
else put 'ERROR: ROUND7_FAIL=B3198 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3198:; quit;
