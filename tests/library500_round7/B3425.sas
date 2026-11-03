/* B3425 datasets_remove_format, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:567 */

data b3425a; x=6; format x date9.; run;
proc datasets library=work nolist; modify b3425a; format x; quit;
proc contents data=b3425a out=b3425b noprint; run;
data b3425o; set b3425b; actual=6+missing(format); run;

data _null_; if 0 then set b3425o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3425 rows=' rows;
else do; set b3425o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3425';
else put 'ERROR: ROUND7_FAIL=B3425 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3425:; quit;
