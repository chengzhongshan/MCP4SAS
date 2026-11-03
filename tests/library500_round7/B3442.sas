/* B3442 sql_ungrouped_having_remerge, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3442a; do x=1 to 3; output; end; run;
proc sql; create table b3442o as select x as actual from b3442a having x=max(x); quit;

data _null_; if 0 then set b3442o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3442 rows=' rows;
else do; set b3442o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3442';
else put 'ERROR: ROUND7_FAIL=B3442 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3442:; quit;
