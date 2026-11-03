/* B3379 rank_percent_sum, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3379a; do x=1 to 10; output; end; run;
proc rank data=b3379a out=b3379b percent; var x; ranks percent; run;
proc sql; create table b3379o as select sum(percent) as actual from b3379b; quit;

data _null_; if 0 then set b3379o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3379 rows=' rows;
else do; set b3379o; if not missing(actual) and abs(actual-(550))<=1e-9*max(1,abs(550)) then put 'ROUND7_PASS=B3379';
else put 'ERROR: ROUND7_FAIL=B3379 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3379:; quit;
