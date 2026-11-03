/* B3021 link_return_subroutine, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3021o; total=0; do x=1 to 2; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3021o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3021 rows=' rows;
else do; set b3021o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3021';
else put 'ERROR: ROUND7_FAIL=B3021 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3021:; quit;
