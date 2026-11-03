/* B3389 transpose_name_metadata, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3389a; x=10; y=11; z=12; run;
proc transpose data=b3389a out=b3389b name=source prefix=val; var x y z; run;
proc sql; create table b3389o as select count(distinct source)+sum(val1) as actual from b3389b; quit;

data _null_; if 0 then set b3389o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3389 rows=' rows;
else do; set b3389o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND7_PASS=B3389';
else put 'ERROR: ROUND7_FAIL=B3389 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3389:; quit;
