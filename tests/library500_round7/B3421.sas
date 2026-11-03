/* B3421 datasets_remove_format, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3421a; x=2; format x date9.; run;
proc datasets library=work nolist; modify b3421a; format x; quit;
proc contents data=b3421a out=b3421b noprint; run;
data b3421o; set b3421b; actual=2+missing(format); run;

data _null_; if 0 then set b3421o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3421 rows=' rows;
else do; set b3421o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3421';
else put 'ERROR: ROUND7_FAIL=B3421 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3421:; quit;
