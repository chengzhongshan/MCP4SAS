/* B3394 transpose_by_notsorted, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3394a; grp=1; value=5; output; grp=2; value=6; output; grp=1; value=7; output; run;
proc transpose data=b3394a out=b3394b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3394o as select sum(val1)+count(*) as actual from b3394b; quit;

data _null_; if 0 then set b3394o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3394 rows=' rows;
else do; set b3394o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3394';
else put 'ERROR: ROUND7_FAIL=B3394 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3394:; quit;
