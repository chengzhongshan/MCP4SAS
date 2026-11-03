/* B3024 link_return_subroutine, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3024o; total=0; do x=1 to 5; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3024o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3024 rows=' rows;
else do; set b3024o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND7_PASS=B3024';
else put 'ERROR: ROUND7_FAIL=B3024 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3024:; quit;
