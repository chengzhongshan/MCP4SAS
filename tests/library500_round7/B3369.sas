/* B3369 rank_nplus1_denominator, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3369a; do x=1 to 10; output; end; run;
proc rank data=b3369a out=b3369b nplus1; var x; ranks fraction; run;
proc sql; create table b3369o as select mean(fraction) as actual from b3369b; quit;

data _null_; if 0 then set b3369o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3369 rows=' rows;
else do; set b3369o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3369';
else put 'ERROR: ROUND7_FAIL=B3369 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3369:; quit;
