/* B3105 merge_one_to_many_retention, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3105a; k=1; value=6; run;
data b3105b; k=1; do j=1 to 6; output; end; run;
data b3105c; merge b3105a b3105b; by k; run;
proc sql; create table b3105o as select sum(value) as actual from b3105c; quit;

data _null_; if 0 then set b3105o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3105 rows=' rows;
else do; set b3105o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND7_PASS=B3105';
else put 'ERROR: ROUND7_FAIL=B3105 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3105:; quit;
