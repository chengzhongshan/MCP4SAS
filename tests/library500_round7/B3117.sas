/* B3117 merge_many_to_many_retention, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3117a; k=1; value=1; output; value=2; output; run;
data b3117b; k=1; do j=1 to 8; output; end; run;
data b3117c; merge b3117a b3117b; by k; run;
proc sql; create table b3117o as select sum(value) as actual from b3117c; quit;

data _null_; if 0 then set b3117o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3117 rows=' rows;
else do; set b3117o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3117';
else put 'ERROR: ROUND7_FAIL=B3117 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3117:; quit;
