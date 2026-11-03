/* B3423 datasets_remove_format, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3423a; x=4; format x date9.; run;
proc datasets library=work nolist; modify b3423a; format x; quit;
proc contents data=b3423a out=b3423b noprint; run;
data b3423o; set b3423b; actual=4+missing(format); run;

data _null_; if 0 then set b3423o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3423 rows=' rows;
else do; set b3423o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3423';
else put 'ERROR: ROUND7_FAIL=B3423 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3423:; quit;
