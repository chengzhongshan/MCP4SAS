/* B3042 do_leave_threshold, N=3; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3042o; actual=0; do x=1 to 100; if x>3 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3042o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3042 rows=' rows;
else do; set b3042o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3042';
else put 'ERROR: ROUND7_FAIL=B3042 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3042:; quit;
