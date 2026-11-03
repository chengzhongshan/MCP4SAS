/* B3366 rank_nplus1_denominator, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3366a; do x=1 to 7; output; end; run;
proc rank data=b3366a out=b3366b nplus1; var x; ranks fraction; run;
proc sql; create table b3366o as select mean(fraction) as actual from b3366b; quit;

data _null_; if 0 then set b3366o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3366 rows=' rows;
else do; set b3366o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3366';
else put 'ERROR: ROUND7_FAIL=B3366 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3366:; quit;
