/* B3025 link_return_subroutine, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3025o; total=0; do x=1 to 6; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3025o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3025 rows=' rows;
else do; set b3025o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND7_PASS=B3025';
else put 'ERROR: ROUND7_FAIL=B3025 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3025:; quit;
