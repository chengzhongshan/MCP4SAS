/* B3103 merge_one_to_many_retention, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3103a; k=1; value=4; run;
data b3103b; k=1; do j=1 to 4; output; end; run;
data b3103c; merge b3103a b3103b; by k; run;
proc sql; create table b3103o as select sum(value) as actual from b3103c; quit;

data _null_; if 0 then set b3103o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3103 rows=' rows;
else do; set b3103o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND7_PASS=B3103';
else put 'ERROR: ROUND7_FAIL=B3103 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3103:; quit;
