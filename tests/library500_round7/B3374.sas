/* B3374 rank_percent_sum, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:1194 */

data b3374a; do x=1 to 5; output; end; run;
proc rank data=b3374a out=b3374b percent; var x; ranks percent; run;
proc sql; create table b3374o as select sum(percent) as actual from b3374b; quit;

data _null_; if 0 then set b3374o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3374 rows=' rows;
else do; set b3374o; if not missing(actual) and abs(actual-(300))<=1e-9*max(1,abs(300)) then put 'ROUND7_PASS=B3374';
else put 'ERROR: ROUND7_FAIL=B3374 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3374:; quit;
