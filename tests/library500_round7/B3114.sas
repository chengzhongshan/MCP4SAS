/* B3114 merge_many_to_many_retention, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3114a; k=1; value=1; output; value=2; output; run;
data b3114b; k=1; do j=1 to 5; output; end; run;
data b3114c; merge b3114a b3114b; by k; run;
proc sql; create table b3114o as select sum(value) as actual from b3114c; quit;

data _null_; if 0 then set b3114o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3114 rows=' rows;
else do; set b3114o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3114';
else put 'ERROR: ROUND7_FAIL=B3114 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3114:; quit;
