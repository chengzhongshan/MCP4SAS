/* B3447 sql_ungrouped_having_remerge, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3447a; do x=1 to 8; output; end; run;
proc sql; create table b3447o as select x as actual from b3447a having x=max(x); quit;

data _null_; if 0 then set b3447o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3447 rows=' rows;
else do; set b3447o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND7_PASS=B3447';
else put 'ERROR: ROUND7_FAIL=B3447 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3447:; quit;
