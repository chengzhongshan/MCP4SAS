/* B3396 transpose_by_notsorted, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3396a; grp=1; value=7; output; grp=2; value=8; output; grp=1; value=9; output; run;
proc transpose data=b3396a out=b3396b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3396o as select sum(val1)+count(*) as actual from b3396b; quit;

data _null_; if 0 then set b3396o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3396 rows=' rows;
else do; set b3396o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND7_PASS=B3396';
else put 'ERROR: ROUND7_FAIL=B3396 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3396:; quit;
