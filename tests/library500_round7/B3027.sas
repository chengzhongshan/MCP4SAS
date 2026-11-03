/* B3027 link_return_subroutine, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3027o; total=0; do x=1 to 8; link square; end; actual=total; output; stop;
square: total=total+x*x; return; run;

data _null_; if 0 then set b3027o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3027 rows=' rows;
else do; set b3027o; if not missing(actual) and abs(actual-(204))<=1e-9*max(1,abs(204)) then put 'ROUND7_PASS=B3027';
else put 'ERROR: ROUND7_FAIL=B3027 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3027:; quit;
