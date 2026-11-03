/* B3384 transpose_name_metadata, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3384a; x=5; y=6; z=7; run;
proc transpose data=b3384a out=b3384b name=source prefix=val; var x y z; run;
proc sql; create table b3384o as select count(distinct source)+sum(val1) as actual from b3384b; quit;

data _null_; if 0 then set b3384o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3384 rows=' rows;
else do; set b3384o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3384';
else put 'ERROR: ROUND7_FAIL=B3384 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3384:; quit;
