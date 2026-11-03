/* B3191 logistic_balanced_intercept, N=2; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3191a; do y=0 to 1; do j=1 to 2; output; end; end; run;
proc logistic data=b3191a noprint; model y(event='1')=; output out=b3191b p=prob; run;
proc sql; create table b3191o as select mean(prob) as actual from b3191b; quit;

data _null_; if 0 then set b3191o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3191 rows=' rows;
else do; set b3191o; if not missing(actual) and abs(actual-(0.5))<=1e-6*max(1,abs(0.5)) then put 'ROUND7_PASS=B3191';
else put 'ERROR: ROUND7_FAIL=B3191 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3191:; quit;
