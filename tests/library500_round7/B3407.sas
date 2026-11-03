/* B3407 datasets_change_member, N=8; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3407a; x=8; run;
proc datasets library=work nolist; change b3407a=b3407b; quit;
data b3407o; actual=8+exist('b3407a')+10*exist('b3407b'); run;

data _null_; if 0 then set b3407o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3407 rows=' rows;
else do; set b3407o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND7_PASS=B3407';
else put 'ERROR: ROUND7_FAIL=B3407 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3407:; quit;
