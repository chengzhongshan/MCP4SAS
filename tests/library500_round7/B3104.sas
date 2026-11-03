/* B3104 merge_one_to_many_retention, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3104a; k=1; value=5; run;
data b3104b; k=1; do j=1 to 5; output; end; run;
data b3104c; merge b3104a b3104b; by k; run;
proc sql; create table b3104o as select sum(value) as actual from b3104c; quit;

data _null_; if 0 then set b3104o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3104 rows=' rows;
else do; set b3104o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND7_PASS=B3104';
else put 'ERROR: ROUND7_FAIL=B3104 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3104:; quit;
