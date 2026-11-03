/* B3400 transpose_by_notsorted, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3400a; grp=1; value=11; output; grp=2; value=12; output; grp=1; value=13; output; run;
proc transpose data=b3400a out=b3400b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3400o as select sum(val1)+count(*) as actual from b3400b; quit;

data _null_; if 0 then set b3400o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3400 rows=' rows;
else do; set b3400o; if not missing(actual) and abs(actual-(39))<=1e-9*max(1,abs(39)) then put 'ROUND7_PASS=B3400';
else put 'ERROR: ROUND7_FAIL=B3400 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3400:; quit;
