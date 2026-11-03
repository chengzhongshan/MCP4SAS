/* B3119 merge_many_to_many_retention, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3119a; k=1; value=1; output; value=2; output; run;
data b3119b; k=1; do j=1 to 10; output; end; run;
data b3119c; merge b3119a b3119b; by k; run;
proc sql; create table b3119o as select sum(value) as actual from b3119c; quit;

data _null_; if 0 then set b3119o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3119 rows=' rows;
else do; set b3119o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND7_PASS=B3119';
else put 'ERROR: ROUND7_FAIL=B3119 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3119:; quit;
