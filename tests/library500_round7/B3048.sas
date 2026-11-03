/* B3048 do_leave_threshold, N=9; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3048o; actual=0; do x=1 to 100; if x>9 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3048o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3048 rows=' rows;
else do; set b3048o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND7_PASS=B3048';
else put 'ERROR: ROUND7_FAIL=B3048 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3048:; quit;
