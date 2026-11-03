/* B3361 rank_nplus1_denominator, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3361a; do x=1 to 2; output; end; run;
proc rank data=b3361a out=b3361b nplus1; var x; ranks fraction; run;
proc sql; create table b3361o as select mean(fraction) as actual from b3361b; quit;

data _null_; if 0 then set b3361o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3361 rows=' rows;
else do; set b3361o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND7_PASS=B3361';
else put 'ERROR: ROUND7_FAIL=B3361 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3361:; quit;
