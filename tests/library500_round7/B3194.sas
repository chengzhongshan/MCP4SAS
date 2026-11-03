/* B3194 logistic_balanced_intercept, N=5; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3194a; do y=0 to 1; do j=1 to 5; output; end; end; run;
proc logistic data=b3194a noprint; model y(event='1')=; output out=b3194b p=prob; run;
proc sql; create table b3194o as select mean(prob) as actual from b3194b; quit;

data _null_; if 0 then set b3194o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3194 rows=' rows;
else do; set b3194o; if not missing(actual) and abs(actual-(0.5))<=1e-6*max(1,abs(0.5)) then put 'ROUND7_PASS=B3194';
else put 'ERROR: ROUND7_FAIL=B3194 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3194:; quit;
