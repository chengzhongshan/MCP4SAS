/* B3401 datasets_change_member, N=2; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3401a; x=2; run;
proc datasets library=work nolist; change b3401a=b3401b; quit;
data b3401o; actual=2+exist('b3401a')+10*exist('b3401b'); run;

data _null_; if 0 then set b3401o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3401 rows=' rows;
else do; set b3401o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3401';
else put 'ERROR: ROUND7_FAIL=B3401 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3401:; quit;
