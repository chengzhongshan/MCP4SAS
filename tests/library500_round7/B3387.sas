/* B3387 transpose_name_metadata, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:2621 */

data b3387a; x=8; y=9; z=10; run;
proc transpose data=b3387a out=b3387b name=source prefix=val; var x y z; run;
proc sql; create table b3387o as select count(distinct source)+sum(val1) as actual from b3387b; quit;

data _null_; if 0 then set b3387o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3387 rows=' rows;
else do; set b3387o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND7_PASS=B3387';
else put 'ERROR: ROUND7_FAIL=B3387 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3387:; quit;
