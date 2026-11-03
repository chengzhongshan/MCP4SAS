/* B3381 transpose_name_metadata, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3381a; x=2; y=3; z=4; run;
proc transpose data=b3381a out=b3381b name=source prefix=val; var x y z; run;
proc sql; create table b3381o as select count(distinct source)+sum(val1) as actual from b3381b; quit;

data _null_; if 0 then set b3381o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3381 rows=' rows;
else do; set b3381o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3381';
else put 'ERROR: ROUND7_FAIL=B3381 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3381:; quit;
