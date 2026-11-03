/* B3022 link_return_subroutine, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3022o; total=0; do x=1 to 3; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3022o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3022 rows=' rows;
else do; set b3022o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND7_PASS=B3022';
else put 'ERROR: ROUND7_FAIL=B3022 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3022:; quit;
