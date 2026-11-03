/* B3110 merge_one_to_many_retention, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:37 */

data b3110a; k=1; value=11; run;
data b3110b; k=1; do j=1 to 11; output; end; run;
data b3110c; merge b3110a b3110b; by k; run;
proc sql; create table b3110o as select sum(value) as actual from b3110c; quit;

data _null_; if 0 then set b3110o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3110 rows=' rows;
else do; set b3110o; if not missing(actual) and abs(actual-(121))<=1e-9*max(1,abs(121)) then put 'ROUND7_PASS=B3110';
else put 'ERROR: ROUND7_FAIL=B3110 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3110:; quit;
