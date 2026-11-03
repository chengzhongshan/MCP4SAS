/* B3353 rank_fraction_denominator, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3353a; do x=1 to 4; output; end; run;
proc rank data=b3353a out=b3353b fraction; var x; ranks fraction; run;
proc sql; create table b3353o as select mean(fraction) as actual from b3353b; quit;

data _null_; if 0 then set b3353o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3353 rows=' rows;
else do; set b3353o; if not missing(actual) and abs(actual-(0.625))<=1e-9*max(1,abs(0.625)) then put 'ROUND7_PASS=B3353';
else put 'ERROR: ROUND7_FAIL=B3353 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3353:; quit;
