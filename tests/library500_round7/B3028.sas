/* B3028 link_return_subroutine, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3028o; total=0; do x=1 to 9; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3028o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3028 rows=' rows;
else do; set b3028o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND7_PASS=B3028';
else put 'ERROR: ROUND7_FAIL=B3028 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3028:; quit;
