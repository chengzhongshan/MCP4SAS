/* B3205 logistic_unbalanced_intercept, N=6; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3205a; do j=1 to 6; y=1; output; y=0; output; output; end; run;
proc logistic data=b3205a noprint; model y(event='1')=; output out=b3205b p=prob; run;
proc sql; create table b3205o as select mean(prob) as actual from b3205b; quit;

data _null_; if 0 then set b3205o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3205 rows=' rows;
else do; set b3205o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-6*max(1,abs(0.333333333333333)) then put 'ROUND7_PASS=B3205';
else put 'ERROR: ROUND7_FAIL=B3205 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3205:; quit;
