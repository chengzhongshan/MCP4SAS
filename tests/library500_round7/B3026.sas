/* B3026 link_return_subroutine, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3026o; total=0; do x=1 to 7; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3026o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3026 rows=' rows;
else do; set b3026o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND7_PASS=B3026';
else put 'ERROR: ROUND7_FAIL=B3026 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3026:; quit;
