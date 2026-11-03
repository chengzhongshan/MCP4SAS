/* B3219 logistic_binary_predictor_cells, N=10; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3219a; do j=1 to 10; grp=0; y=1; output; y=0; output; output; grp=1; y=0; output; y=1; output; output; end; run;
proc logistic data=b3219a noprint; model y(event='1')=grp / gconv=1e-12; output out=b3219b p=prob; run;
proc sql; create table b3219o as select mean(prob) as actual from b3219b where grp=1; quit;

data _null_; if 0 then set b3219o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3219 rows=' rows;
else do; set b3219o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3219';
else put 'ERROR: ROUND7_FAIL=B3219 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3219:; quit;
