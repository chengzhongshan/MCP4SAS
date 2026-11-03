/* B3446 sql_ungrouped_having_remerge, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3446a; do x=1 to 7; output; end; run;
proc sql; create table b3446o as select x as actual from b3446a having x=max(x); quit;

data _null_; if 0 then set b3446o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3446 rows=' rows;
else do; set b3446o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3446';
else put 'ERROR: ROUND7_FAIL=B3446 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3446:; quit;
