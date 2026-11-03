/* B3111 merge_many_to_many_retention, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3111a; k=1; value=1; output; value=2; output; run;
data b3111b; k=1; do j=1 to 2; output; end; run;
data b3111c; merge b3111a b3111b; by k; run;
proc sql; create table b3111o as select sum(value) as actual from b3111c; quit;

data _null_; if 0 then set b3111o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3111 rows=' rows;
else do; set b3111o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3111';
else put 'ERROR: ROUND7_FAIL=B3111 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3111:; quit;
