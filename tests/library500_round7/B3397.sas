/* B3397 transpose_by_notsorted, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3397a; grp=1; value=8; output; grp=2; value=9; output; grp=1; value=10; output; run;
proc transpose data=b3397a out=b3397b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3397o as select sum(val1)+count(*) as actual from b3397b; quit;

data _null_; if 0 then set b3397o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3397 rows=' rows;
else do; set b3397o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND7_PASS=B3397';
else put 'ERROR: ROUND7_FAIL=B3397 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3397:; quit;
