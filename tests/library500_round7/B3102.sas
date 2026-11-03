/* B3102 merge_one_to_many_retention, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3102a; k=1; value=3; run;
data b3102b; k=1; do j=1 to 3; output; end; run;
data b3102c; merge b3102a b3102b; by k; run;
proc sql; create table b3102o as select sum(value) as actual from b3102c; quit;

data _null_; if 0 then set b3102o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3102 rows=' rows;
else do; set b3102o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3102';
else put 'ERROR: ROUND7_FAIL=B3102 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3102:; quit;
