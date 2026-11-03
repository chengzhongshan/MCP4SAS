/* B3045 do_leave_threshold, N=6; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3045o; actual=0; do x=1 to 100; if x>6 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3045o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3045 rows=' rows;
else do; set b3045o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3045';
else put 'ERROR: ROUND7_FAIL=B3045 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3045:; quit;
