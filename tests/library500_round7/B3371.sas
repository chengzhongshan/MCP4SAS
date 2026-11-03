/* B3371 rank_percent_sum, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3371a; do x=1 to 2; output; end; run;
proc rank data=b3371a out=b3371b percent; var x; ranks percent; run;
proc sql; create table b3371o as select sum(percent) as actual from b3371b; quit;

data _null_; if 0 then set b3371o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3371 rows=' rows;
else do; set b3371o; if not missing(actual) and abs(actual-(150))<=1e-9*max(1,abs(150)) then put 'ROUND7_PASS=B3371';
else put 'ERROR: ROUND7_FAIL=B3371 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3371:; quit;
