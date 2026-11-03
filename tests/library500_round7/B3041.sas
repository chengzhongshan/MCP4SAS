/* B3041 do_leave_threshold, N=2; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3041o; actual=0; do x=1 to 100; if x>2 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3041o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3041 rows=' rows;
else do; set b3041o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3041';
else put 'ERROR: ROUND7_FAIL=B3041 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3041:; quit;
