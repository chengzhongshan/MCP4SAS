/* B3388 transpose_name_metadata, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3388a; x=9; y=10; z=11; run;
proc transpose data=b3388a out=b3388b name=source prefix=val; var x y z; run;
proc sql; create table b3388o as select count(distinct source)+sum(val1) as actual from b3388b; quit;

data _null_; if 0 then set b3388o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3388 rows=' rows;
else do; set b3388o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND7_PASS=B3388';
else put 'ERROR: ROUND7_FAIL=B3388 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3388:; quit;
