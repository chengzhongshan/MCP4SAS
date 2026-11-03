/* B3120 merge_many_to_many_retention, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3120a; k=1; value=1; output; value=2; output; run;
data b3120b; k=1; do j=1 to 11; output; end; run;
data b3120c; merge b3120a b3120b; by k; run;
proc sql; create table b3120o as select sum(value) as actual from b3120c; quit;

data _null_; if 0 then set b3120o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3120 rows=' rows;
else do; set b3120o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3120';
else put 'ERROR: ROUND7_FAIL=B3120 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3120:; quit;
