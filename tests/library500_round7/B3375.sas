/* B3375 rank_percent_sum, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3375a; do x=1 to 6; output; end; run;
proc rank data=b3375a out=b3375b percent; var x; ranks percent; run;
proc sql; create table b3375o as select sum(percent) as actual from b3375b; quit;

data _null_; if 0 then set b3375o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3375 rows=' rows;
else do; set b3375o; if not missing(actual) and abs(actual-(350))<=1e-9*max(1,abs(350)) then put 'ROUND7_PASS=B3375';
else put 'ERROR: ROUND7_FAIL=B3375 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3375:; quit;
