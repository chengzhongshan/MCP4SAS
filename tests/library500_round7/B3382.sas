/* B3382 transpose_name_metadata, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3382a; x=3; y=4; z=5; run;
proc transpose data=b3382a out=b3382b name=source prefix=val; var x y z; run;
proc sql; create table b3382o as select count(distinct source)+sum(val1) as actual from b3382b; quit;

data _null_; if 0 then set b3382o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3382 rows=' rows;
else do; set b3382o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3382';
else put 'ERROR: ROUND7_FAIL=B3382 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3382:; quit;
