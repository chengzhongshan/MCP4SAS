/* B3113 merge_many_to_many_retention, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3113a; k=1; value=1; output; value=2; output; run;
data b3113b; k=1; do j=1 to 4; output; end; run;
data b3113c; merge b3113a b3113b; by k; run;
proc sql; create table b3113o as select sum(value) as actual from b3113c; quit;

data _null_; if 0 then set b3113o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3113 rows=' rows;
else do; set b3113o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3113';
else put 'ERROR: ROUND7_FAIL=B3113 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3113:; quit;
