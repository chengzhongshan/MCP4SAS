/* B3043 do_leave_threshold, N=4; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3043o; actual=0; do x=1 to 100; if x>4 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3043o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3043 rows=' rows;
else do; set b3043o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND7_PASS=B3043';
else put 'ERROR: ROUND7_FAIL=B3043 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3043:; quit;
