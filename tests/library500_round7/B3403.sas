/* B3403 datasets_change_member, N=4; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3403a; x=4; run;
proc datasets library=work nolist; change b3403a=b3403b; quit;
data b3403o; actual=4+exist('b3403a')+10*exist('b3403b'); run;

data _null_; if 0 then set b3403o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3403 rows=' rows;
else do; set b3403o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND7_PASS=B3403';
else put 'ERROR: ROUND7_FAIL=B3403 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3403:; quit;
