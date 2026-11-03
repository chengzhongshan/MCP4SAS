/* B3448 sql_ungrouped_having_remerge, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3448a; do x=1 to 9; output; end; run;
proc sql; create table b3448o as select x as actual from b3448a having x=max(x); quit;

data _null_; if 0 then set b3448o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3448 rows=' rows;
else do; set b3448o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3448';
else put 'ERROR: ROUND7_FAIL=B3448 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3448:; quit;
