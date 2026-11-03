/* B3372 rank_percent_sum, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3372a; do x=1 to 3; output; end; run;
proc rank data=b3372a out=b3372b percent; var x; ranks percent; run;
proc sql; create table b3372o as select sum(percent) as actual from b3372b; quit;

data _null_; if 0 then set b3372o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3372 rows=' rows;
else do; set b3372o; if not missing(actual) and abs(actual-(200))<=1e-9*max(1,abs(200)) then put 'ROUND7_PASS=B3372';
else put 'ERROR: ROUND7_FAIL=B3372 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3372:; quit;
