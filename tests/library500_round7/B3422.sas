/* B3422 datasets_remove_format, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3422a; x=3; format x date9.; run;
proc datasets library=work nolist; modify b3422a; format x; quit;
proc contents data=b3422a out=b3422b noprint; run;
data b3422o; set b3422b; actual=3+missing(format); run;

data _null_; if 0 then set b3422o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3422 rows=' rows;
else do; set b3422o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND7_PASS=B3422';
else put 'ERROR: ROUND7_FAIL=B3422 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3422:; quit;
