/* B3429 datasets_remove_format, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3429a; x=10; format x date9.; run;
proc datasets library=work nolist; modify b3429a; format x; quit;
proc contents data=b3429a out=b3429b noprint; run;
data b3429o; set b3429b; actual=10+missing(format); run;

data _null_; if 0 then set b3429o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3429 rows=' rows;
else do; set b3429o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND7_PASS=B3429';
else put 'ERROR: ROUND7_FAIL=B3429 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3429:; quit;
