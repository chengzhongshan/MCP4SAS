/* B3405 datasets_change_member, N=6; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3405a; x=6; run;
proc datasets library=work nolist; change b3405a=b3405b; quit;
data b3405o; actual=6+exist('b3405a')+10*exist('b3405b'); run;

data _null_; if 0 then set b3405o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3405 rows=' rows;
else do; set b3405o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND7_PASS=B3405';
else put 'ERROR: ROUND7_FAIL=B3405 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3405:; quit;
