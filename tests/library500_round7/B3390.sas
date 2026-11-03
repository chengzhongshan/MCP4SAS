/* B3390 transpose_name_metadata, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3390a; x=11; y=12; z=13; run;
proc transpose data=b3390a out=b3390b name=source prefix=val; var x y z; run;
proc sql; create table b3390o as select count(distinct source)+sum(val1) as actual from b3390b; quit;

data _null_; if 0 then set b3390o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3390 rows=' rows;
else do; set b3390o; if not missing(actual) and abs(actual-(39))<=1e-9*max(1,abs(39)) then put 'ROUND7_PASS=B3390';
else put 'ERROR: ROUND7_FAIL=B3390 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3390:; quit;
