/* B3363 rank_nplus1_denominator, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3363a; do x=1 to 4; output; end; run;
proc rank data=b3363a out=b3363b nplus1; var x; ranks fraction; run;
proc sql; create table b3363o as select mean(fraction) as actual from b3363b; quit;

data _null_; if 0 then set b3363o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3363 rows=' rows;
else do; set b3363o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3363';
else put 'ERROR: ROUND7_FAIL=B3363 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3363:; quit;
