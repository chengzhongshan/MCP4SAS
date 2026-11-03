/* B3424 datasets_remove_format, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3424a; x=5; format x date9.; run;
proc datasets library=work nolist; modify b3424a; format x; quit;
proc contents data=b3424a out=b3424b noprint; run;
data b3424o; set b3424b; actual=5+missing(format); run;

data _null_; if 0 then set b3424o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3424 rows=' rows;
else do; set b3424o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3424';
else put 'ERROR: ROUND7_FAIL=B3424 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3424:; quit;
