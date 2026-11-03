/* B3370 rank_nplus1_denominator, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3370a; do x=1 to 11; output; end; run;
proc rank data=b3370a out=b3370b nplus1; var x; ranks fraction; run;
proc sql; create table b3370o as select mean(fraction) as actual from b3370b; quit;

data _null_; if 0 then set b3370o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3370 rows=' rows;
else do; set b3370o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3370';
else put 'ERROR: ROUND7_FAIL=B3370 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3370:; quit;
