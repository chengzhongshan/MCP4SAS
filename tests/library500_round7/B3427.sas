/* B3427 datasets_remove_format, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3427a; x=8; format x date9.; run;
proc datasets library=work nolist; modify b3427a; format x; quit;
proc contents data=b3427a out=b3427b noprint; run;
data b3427o; set b3427b; actual=8+missing(format); run;

data _null_; if 0 then set b3427o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3427 rows=' rows;
else do; set b3427o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3427';
else put 'ERROR: ROUND7_FAIL=B3427 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3427:; quit;
