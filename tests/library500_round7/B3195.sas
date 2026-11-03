/* B3195 logistic_balanced_intercept, N=6; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3195a; do y=0 to 1; do j=1 to 6; output; end; end; run;
proc logistic data=b3195a noprint; model y(event='1')=; output out=b3195b p=prob; run;
proc sql; create table b3195o as select mean(prob) as actual from b3195b; quit;

data _null_; if 0 then set b3195o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3195 rows=' rows;
else do; set b3195o; if not missing(actual) and abs(actual-(0.5))<=1e-6*max(1,abs(0.5)) then put 'ROUND7_PASS=B3195';
else put 'ERROR: ROUND7_FAIL=B3195 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3195:; quit;
