/* B3108 merge_one_to_many_retention, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3108a; k=1; value=9; run;
data b3108b; k=1; do j=1 to 9; output; end; run;
data b3108c; merge b3108a b3108b; by k; run;
proc sql; create table b3108o as select sum(value) as actual from b3108c; quit;

data _null_; if 0 then set b3108o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3108 rows=' rows;
else do; set b3108o; if not missing(actual) and abs(actual-(81))<=1e-9*max(1,abs(81)) then put 'ROUND7_PASS=B3108';
else put 'ERROR: ROUND7_FAIL=B3108 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3108:; quit;
