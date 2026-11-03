/* B3409 datasets_change_member, N=10; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3409a; x=10; run;
proc datasets library=work nolist; change b3409a=b3409b; quit;
data b3409o; actual=10+exist('b3409a')+10*exist('b3409b'); run;

data _null_; if 0 then set b3409o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3409 rows=' rows;
else do; set b3409o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND7_PASS=B3409';
else put 'ERROR: ROUND7_FAIL=B3409 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3409:; quit;
