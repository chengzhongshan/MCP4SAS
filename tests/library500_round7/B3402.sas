/* B3402 datasets_change_member, N=3; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3402a; x=3; run;
proc datasets library=work nolist; change b3402a=b3402b; quit;
data b3402o; actual=3+exist('b3402a')+10*exist('b3402b'); run;

data _null_; if 0 then set b3402o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3402 rows=' rows;
else do; set b3402o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND7_PASS=B3402';
else put 'ERROR: ROUND7_FAIL=B3402 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3402:; quit;
