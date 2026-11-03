/* B3398 transpose_by_notsorted, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3398a; grp=1; value=9; output; grp=2; value=10; output; grp=1; value=11; output; run;
proc transpose data=b3398a out=b3398b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3398o as select sum(val1)+count(*) as actual from b3398b; quit;

data _null_; if 0 then set b3398o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3398 rows=' rows;
else do; set b3398o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND7_PASS=B3398';
else put 'ERROR: ROUND7_FAIL=B3398 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3398:; quit;
