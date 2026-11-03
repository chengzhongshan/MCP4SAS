/* B3385 transpose_name_metadata, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3385a; x=6; y=7; z=8; run;
proc transpose data=b3385a out=b3385b name=source prefix=val; var x y z; run;
proc sql; create table b3385o as select count(distinct source)+sum(val1) as actual from b3385b; quit;

data _null_; if 0 then set b3385o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3385 rows=' rows;
else do; set b3385o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND7_PASS=B3385';
else put 'ERROR: ROUND7_FAIL=B3385 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3385:; quit;
