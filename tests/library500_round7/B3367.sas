/* B3367 rank_nplus1_denominator, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3367a; do x=1 to 8; output; end; run;
proc rank data=b3367a out=b3367b nplus1; var x; ranks fraction; run;
proc sql; create table b3367o as select mean(fraction) as actual from b3367b; quit;

data _null_; if 0 then set b3367o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3367 rows=' rows;
else do; set b3367o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3367';
else put 'ERROR: ROUND7_FAIL=B3367 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3367:; quit;
