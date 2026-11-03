/* B3377 rank_percent_sum, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3377a; do x=1 to 8; output; end; run;
proc rank data=b3377a out=b3377b percent; var x; ranks percent; run;
proc sql; create table b3377o as select sum(percent) as actual from b3377b; quit;

data _null_; if 0 then set b3377o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3377 rows=' rows;
else do; set b3377o; if not missing(actual) and abs(actual-(450))<=1e-9*max(1,abs(450)) then put 'ROUND7_PASS=B3377';
else put 'ERROR: ROUND7_FAIL=B3377 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3377:; quit;
