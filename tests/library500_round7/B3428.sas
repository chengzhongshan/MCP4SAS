/* B3428 datasets_remove_format, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3428a; x=9; format x date9.; run;
proc datasets library=work nolist; modify b3428a; format x; quit;
proc contents data=b3428a out=b3428b noprint; run;
data b3428o; set b3428b; actual=9+missing(format); run;

data _null_; if 0 then set b3428o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3428 rows=' rows;
else do; set b3428o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND7_PASS=B3428';
else put 'ERROR: ROUND7_FAIL=B3428 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3428:; quit;
