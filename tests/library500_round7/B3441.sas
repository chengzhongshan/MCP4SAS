/* B3441 sql_ungrouped_having_remerge, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3441a; do x=1 to 2; output; end; run;
proc sql; create table b3441o as select x as actual from b3441a having x=max(x); quit;

data _null_; if 0 then set b3441o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3441 rows=' rows;
else do; set b3441o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND7_PASS=B3441';
else put 'ERROR: ROUND7_FAIL=B3441 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3441:; quit;
