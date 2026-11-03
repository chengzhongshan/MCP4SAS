/* B3399 transpose_by_notsorted, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3399a; grp=1; value=10; output; grp=2; value=11; output; grp=1; value=12; output; run;
proc transpose data=b3399a out=b3399b prefix=val; by grp notsorted; var value; run;
proc sql; create table b3399o as select sum(val1)+count(*) as actual from b3399b; quit;

data _null_; if 0 then set b3399o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3399 rows=' rows;
else do; set b3399o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND7_PASS=B3399';
else put 'ERROR: ROUND7_FAIL=B3399 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3399:; quit;
