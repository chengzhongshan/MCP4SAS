/* B3030 link_return_subroutine, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3030o; total=0; do x=1 to 11; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3030o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3030 rows=' rows;
else do; set b3030o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND7_PASS=B3030';
else put 'ERROR: ROUND7_FAIL=B3030 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3030:; quit;
