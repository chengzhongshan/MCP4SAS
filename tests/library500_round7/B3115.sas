/* B3115 merge_many_to_many_retention, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3115a; k=1; value=1; output; value=2; output; run;
data b3115b; k=1; do j=1 to 6; output; end; run;
data b3115c; merge b3115a b3115b; by k; run;
proc sql; create table b3115o as select sum(value) as actual from b3115c; quit;

data _null_; if 0 then set b3115o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3115 rows=' rows;
else do; set b3115o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND7_PASS=B3115';
else put 'ERROR: ROUND7_FAIL=B3115 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3115:; quit;
