/* B3357 rank_fraction_denominator, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3357a; do x=1 to 8; output; end; run;
proc rank data=b3357a out=b3357b fraction; var x; ranks fraction; run;
proc sql; create table b3357o as select mean(fraction) as actual from b3357b; quit;

data _null_; if 0 then set b3357o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3357 rows=' rows;
else do; set b3357o; if not missing(actual) and abs(actual-(0.5625))<=1e-9*max(1,abs(0.5625)) then put 'ROUND7_PASS=B3357';
else put 'ERROR: ROUND7_FAIL=B3357 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3357:; quit;
