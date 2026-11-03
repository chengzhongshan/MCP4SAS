/* B3404 datasets_change_member, N=5; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3404a; x=5; run;
proc datasets library=work nolist; change b3404a=b3404b; quit;
data b3404o; actual=5+exist('b3404a')+10*exist('b3404b'); run;

data _null_; if 0 then set b3404o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3404 rows=' rows;
else do; set b3404o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3404';
else put 'ERROR: ROUND7_FAIL=B3404 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3404:; quit;
