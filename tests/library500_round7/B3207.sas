/* B3207 logistic_unbalanced_intercept, N=8; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3207a; do j=1 to 8; y=1; output; y=0; output; output; end; run;
proc logistic data=b3207a noprint; model y(event='1')=; output out=b3207b p=prob; run;
proc sql; create table b3207o as select mean(prob) as actual from b3207b; quit;

data _null_; if 0 then set b3207o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3207 rows=' rows;
else do; set b3207o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-6*max(1,abs(0.333333333333333)) then put 'ROUND7_PASS=B3207';
else put 'ERROR: ROUND7_FAIL=B3207 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3207:; quit;
