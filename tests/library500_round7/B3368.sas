/* B3368 rank_nplus1_denominator, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3368a; do x=1 to 9; output; end; run;
proc rank data=b3368a out=b3368b nplus1; var x; ranks fraction; run;
proc sql; create table b3368o as select mean(fraction) as actual from b3368b; quit;

data _null_; if 0 then set b3368o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3368 rows=' rows;
else do; set b3368o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3368';
else put 'ERROR: ROUND7_FAIL=B3368 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3368:; quit;
