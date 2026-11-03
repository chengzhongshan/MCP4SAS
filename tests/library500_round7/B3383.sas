/* B3383 transpose_name_metadata, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3383a; x=4; y=5; z=6; run;
proc transpose data=b3383a out=b3383b name=source prefix=val; var x y z; run;
proc sql; create table b3383o as select count(distinct source)+sum(val1) as actual from b3383b; quit;

data _null_; if 0 then set b3383o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3383 rows=' rows;
else do; set b3383o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND7_PASS=B3383';
else put 'ERROR: ROUND7_FAIL=B3383 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3383:; quit;
