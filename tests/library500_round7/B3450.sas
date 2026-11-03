/* B3450 sql_ungrouped_having_remerge, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data b3450a; do x=1 to 11; output; end; run;
proc sql; create table b3450o as select x as actual from b3450a having x=max(x); quit;

data _null_; if 0 then set b3450o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3450 rows=' rows;
else do; set b3450o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND7_PASS=B3450';
else put 'ERROR: ROUND7_FAIL=B3450 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3450:; quit;
