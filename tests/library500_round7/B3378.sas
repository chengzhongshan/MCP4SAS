/* B3378 rank_percent_sum, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3378a; do x=1 to 9; output; end; run;
proc rank data=b3378a out=b3378b percent; var x; ranks percent; run;
proc sql; create table b3378o as select sum(percent) as actual from b3378b; quit;

data _null_; if 0 then set b3378o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3378 rows=' rows;
else do; set b3378o; if not missing(actual) and abs(actual-(500))<=1e-9*max(1,abs(500)) then put 'ROUND7_PASS=B3378';
else put 'ERROR: ROUND7_FAIL=B3378 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3378:; quit;
