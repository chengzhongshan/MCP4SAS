/* B3406 datasets_change_member, N=7; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3406a; x=7; run;
proc datasets library=work nolist; change b3406a=b3406b; quit;
data b3406o; actual=7+exist('b3406a')+10*exist('b3406b'); run;

data _null_; if 0 then set b3406o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3406 rows=' rows;
else do; set b3406o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND7_PASS=B3406';
else put 'ERROR: ROUND7_FAIL=B3406 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3406:; quit;
