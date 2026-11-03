/* B3392 transpose_by_notsorted, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3392a; grp=1; value=3; output; grp=2; value=4; output; grp=1; value=5; output; run;
proc transpose data=b3392a out=b3392b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3392o as select sum(val1)+count(*) as actual from b3392b; quit;

data _null_; if 0 then set b3392o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3392 rows=' rows;
else do; set b3392o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3392';
else put 'ERROR: ROUND7_FAIL=B3392 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3392:; quit;
