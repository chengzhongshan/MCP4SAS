/* B3395 transpose_by_notsorted, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3395a; grp=1; value=6; output; grp=2; value=7; output; grp=1; value=8; output; run;
proc transpose data=b3395a out=b3395b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3395o as select sum(val1)+count(*) as actual from b3395b; quit;

data _null_; if 0 then set b3395o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3395 rows=' rows;
else do; set b3395o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND7_PASS=B3395';
else put 'ERROR: ROUND7_FAIL=B3395 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3395:; quit;
