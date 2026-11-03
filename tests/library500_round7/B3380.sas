/* B3380 rank_percent_sum, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3380a; do x=1 to 11; output; end; run;
proc rank data=b3380a out=b3380b percent; var x; ranks percent; run;
proc sql; create table b3380o as select sum(percent) as actual from b3380b; quit;

data _null_; if 0 then set b3380o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3380 rows=' rows;
else do; set b3380o; if not missing(actual) and abs(actual-(600))<=1e-9*max(1,abs(600)) then put 'ROUND7_PASS=B3380';
else put 'ERROR: ROUND7_FAIL=B3380 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3380:; quit;
