/* B3444 sql_ungrouped_having_remerge, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3444a; do x=1 to 5; output; end; run;
proc sql; create table b3444o as select x as actual from b3444a having x=max(x); quit;

data _null_; if 0 then set b3444o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3444 rows=' rows;
else do; set b3444o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3444';
else put 'ERROR: ROUND7_FAIL=B3444 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3444:; quit;
