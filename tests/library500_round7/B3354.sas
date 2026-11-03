/* B3354 rank_fraction_denominator, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3354a; do x=1 to 5; output; end; run;
proc rank data=b3354a out=b3354b fraction; var x; ranks fraction; run;
proc sql; create table b3354o as select mean(fraction) as actual from b3354b; quit;

data _null_; if 0 then set b3354o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3354 rows=' rows;
else do; set b3354o; if not missing(actual) and abs(actual-(0.6))<=1e-9*max(1,abs(0.6)) then put 'ROUND7_PASS=B3354';
else put 'ERROR: ROUND7_FAIL=B3354 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3354:; quit;
