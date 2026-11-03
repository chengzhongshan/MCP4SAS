/* B3410 datasets_change_member, N=11; source: Cody's Data Cleaning Techniques Using SAS Software.txt:720 */

data b3410a; x=11; run;
proc datasets library=work nolist; change b3410a=b3410b; quit;
data b3410o; actual=11+exist('b3410a')+10*exist('b3410b'); run;

data _null_; if 0 then set b3410o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3410 rows=' rows;
else do; set b3410o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3410';
else put 'ERROR: ROUND7_FAIL=B3410 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3410:; quit;
