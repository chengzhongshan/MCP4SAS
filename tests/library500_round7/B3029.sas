/* B3029 link_return_subroutine, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3029o; total=0; do x=1 to 10; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3029o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3029 rows=' rows;
else do; set b3029o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND7_PASS=B3029';
else put 'ERROR: ROUND7_FAIL=B3029 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3029:; quit;
