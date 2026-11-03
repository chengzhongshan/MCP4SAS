/* B3449 sql_ungrouped_having_remerge, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3449a; do x=1 to 10; output; end; run;
proc sql; create table b3449o as select x as actual from b3449a having x=max(x); quit;

data _null_; if 0 then set b3449o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3449 rows=' rows;
else do; set b3449o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND7_PASS=B3449';
else put 'ERROR: ROUND7_FAIL=B3449 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3449:; quit;
