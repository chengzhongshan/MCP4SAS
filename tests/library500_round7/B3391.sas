/* B3391 transpose_by_notsorted, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3391a; grp=1; value=2; output; grp=2; value=3; output; grp=1; value=4; output; run;
proc transpose data=b3391a out=b3391b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3391o as select sum(val1)+count(*) as actual from b3391b; quit;

data _null_; if 0 then set b3391o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3391 rows=' rows;
else do; set b3391o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3391';
else put 'ERROR: ROUND7_FAIL=B3391 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3391:; quit;
