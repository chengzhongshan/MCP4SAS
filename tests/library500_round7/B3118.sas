/* B3118 merge_many_to_many_retention, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3118a; k=1; value=1; output; value=2; output; run;
data b3118b; k=1; do j=1 to 9; output; end; run;
data b3118c; merge b3118a b3118b; by k; run;
proc sql; create table b3118o as select sum(value) as actual from b3118c; quit;

data _null_; if 0 then set b3118o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3118 rows=' rows;
else do; set b3118o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND7_PASS=B3118';
else put 'ERROR: ROUND7_FAIL=B3118 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3118:; quit;
