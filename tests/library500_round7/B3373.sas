/* B3373 rank_percent_sum, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3373a; do x=1 to 4; output; end; run;
proc rank data=b3373a out=b3373b percent; var x; ranks percent; run;
proc sql; create table b3373o as select sum(percent) as actual from b3373b; quit;

data _null_; if 0 then set b3373o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3373 rows=' rows;
else do; set b3373o; if not missing(actual) and abs(actual-(250))<=1e-9*max(1,abs(250)) then put 'ROUND7_PASS=B3373';
else put 'ERROR: ROUND7_FAIL=B3373 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3373:; quit;
