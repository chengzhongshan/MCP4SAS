/* B3112 merge_many_to_many_retention, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3112a; k=1; value=1; output; value=2; output; run;
data b3112b; k=1; do j=1 to 3; output; end; run;
data b3112c; merge b3112a b3112b; by k; run;
proc sql; create table b3112o as select sum(value) as actual from b3112c; quit;

data _null_; if 0 then set b3112o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3112 rows=' rows;
else do; set b3112o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3112';
else put 'ERROR: ROUND7_FAIL=B3112 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3112:; quit;
