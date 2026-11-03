/* B3408 datasets_change_member, N=9; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3408a; x=9; run;
proc datasets library=work nolist; change b3408a=b3408b; quit;
data b3408o; actual=9+exist('b3408a')+10*exist('b3408b'); run;

data _null_; if 0 then set b3408o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3408 rows=' rows;
else do; set b3408o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND7_PASS=B3408';
else put 'ERROR: ROUND7_FAIL=B3408 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3408:; quit;
