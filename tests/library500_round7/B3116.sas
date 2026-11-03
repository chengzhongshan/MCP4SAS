/* B3116 merge_many_to_many_retention, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3116a; k=1; value=1; output; value=2; output; run;
data b3116b; k=1; do j=1 to 7; output; end; run;
data b3116c; merge b3116a b3116b; by k; run;
proc sql; create table b3116o as select sum(value) as actual from b3116c; quit;

data _null_; if 0 then set b3116o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3116 rows=' rows;
else do; set b3116o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND7_PASS=B3116';
else put 'ERROR: ROUND7_FAIL=B3116 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3116:; quit;
