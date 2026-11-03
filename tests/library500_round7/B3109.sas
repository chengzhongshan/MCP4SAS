/* B3109 merge_one_to_many_retention, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3109a; k=1; value=10; run;
data b3109b; k=1; do j=1 to 10; output; end; run;
data b3109c; merge b3109a b3109b; by k; run;
proc sql; create table b3109o as select sum(value) as actual from b3109c; quit;

data _null_; if 0 then set b3109o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3109 rows=' rows;
else do; set b3109o; if not missing(actual) and abs(actual-(100))<=1e-9*max(1,abs(100)) then put 'ROUND7_PASS=B3109';
else put 'ERROR: ROUND7_FAIL=B3109 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3109:; quit;
