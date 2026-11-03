/* B3386 transpose_name_metadata, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3386a; x=7; y=8; z=9; run;
proc transpose data=b3386a out=b3386b name=source prefix=val; var x y z; run;
proc sql; create table b3386o as select count(distinct source)+sum(val1) as actual from b3386b; quit;

data _null_; if 0 then set b3386o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3386 rows=' rows;
else do; set b3386o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND7_PASS=B3386';
else put 'ERROR: ROUND7_FAIL=B3386 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3386:; quit;
