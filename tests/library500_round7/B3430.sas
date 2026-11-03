/* B3430 datasets_remove_format, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3430a; x=11; format x date9.; run;
proc datasets library=work nolist; modify b3430a; format x; quit;
proc contents data=b3430a out=b3430b noprint; run;
data b3430o; set b3430b; actual=11+missing(format); run;

data _null_; if 0 then set b3430o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3430 rows=' rows;
else do; set b3430o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3430';
else put 'ERROR: ROUND7_FAIL=B3430 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3430:; quit;
