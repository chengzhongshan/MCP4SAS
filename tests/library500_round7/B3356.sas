/* B3356 rank_fraction_denominator, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3356a; do x=1 to 7; output; end; run;
proc rank data=b3356a out=b3356b fraction; var x; ranks fraction; run;
proc sql; create table b3356o as select mean(fraction) as actual from b3356b; quit;

data _null_; if 0 then set b3356o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3356 rows=' rows;
else do; set b3356o; if not missing(actual) and abs(actual-(0.571428571428571))<=1e-9*max(1,abs(0.571428571428571)) then put 'ROUND7_PASS=B3356';
else put 'ERROR: ROUND7_FAIL=B3356 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3356:; quit;
