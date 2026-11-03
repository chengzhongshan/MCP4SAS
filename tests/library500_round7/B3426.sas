/* B3426 datasets_remove_format, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3426a; x=7; format x date9.; run;
proc datasets library=work nolist; modify b3426a; format x; quit;
proc contents data=b3426a out=b3426b noprint; run;
data b3426o; set b3426b; actual=7+missing(format); run;

data _null_; if 0 then set b3426o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3426 rows=' rows;
else do; set b3426o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND7_PASS=B3426';
else put 'ERROR: ROUND7_FAIL=B3426 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3426:; quit;
