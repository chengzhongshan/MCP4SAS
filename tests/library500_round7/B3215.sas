/* B3215 logistic_binary_predictor_cells, N=6; source: Categorical Data Analysis Using the SAS System.txt:1008 */

data b3215a; do j=1 to 6; grp=0; y=1; output; y=0; output; output; grp=1; y=0; output; y=1; output; output; end; run;
proc logistic data=b3215a noprint; model y(event='1')=grp / gconv=1e-12; output out=b3215b p=prob; run;
proc sql; create table b3215o as select mean(prob) as actual from b3215b where grp=1; quit;

data _null_; if 0 then set b3215o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3215 rows=' rows;
else do; set b3215o; if not missing(actual) and abs(actual-(0.666666666666667))<=1e-6*max(1,abs(0.666666666666667)) then put 'ROUND7_PASS=B3215';
else put 'ERROR: ROUND7_FAIL=B3215 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3215:; quit;
