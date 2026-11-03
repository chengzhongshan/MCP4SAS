/* B3364 rank_nplus1_denominator, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3364a; do x=1 to 5; output; end; run;
proc rank data=b3364a out=b3364b nplus1; var x; ranks fraction; run;
proc sql; create table b3364o as select mean(fraction) as actual from b3364b; quit;

data _null_; if 0 then set b3364o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3364 rows=' rows;
else do; set b3364o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3364';
else put 'ERROR: ROUND7_FAIL=B3364 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3364:; quit;
