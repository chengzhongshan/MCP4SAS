/* B3107 merge_one_to_many_retention, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3107a; k=1; value=8; run;
data b3107b; k=1; do j=1 to 8; output; end; run;
data b3107c; merge b3107a b3107b; by k; run;
proc sql; create table b3107o as select sum(value) as actual from b3107c; quit;

data _null_; if 0 then set b3107o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3107 rows=' rows;
else do; set b3107o; if not missing(actual) and abs(actual-(64))<=1e-9*max(1,abs(64)) then put 'ROUND7_PASS=B3107';
else put 'ERROR: ROUND7_FAIL=B3107 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3107:; quit;
