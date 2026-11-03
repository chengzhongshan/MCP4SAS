/* B3393 transpose_by_notsorted, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3393a; grp=1; value=4; output; grp=2; value=5; output; grp=1; value=6; output; run;
proc transpose data=b3393a out=b3393b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3393o as select sum(val1)+count(*) as actual from b3393b; quit;

data _null_; if 0 then set b3393o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3393 rows=' rows;
else do; set b3393o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND7_PASS=B3393';
else put 'ERROR: ROUND7_FAIL=B3393 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3393:; quit;
