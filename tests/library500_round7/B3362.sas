/* B3362 rank_nplus1_denominator, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3362a; do x=1 to 3; output; end; run;
proc rank data=b3362a out=b3362b nplus1; var x; ranks fraction; run;
proc sql; create table b3362o as select mean(fraction) as actual from b3362b; quit;

data _null_; if 0 then set b3362o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3362 rows=' rows;
else do; set b3362o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3362';
else put 'ERROR: ROUND7_FAIL=B3362 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3362:; quit;
