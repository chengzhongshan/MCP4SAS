/* B3046 do_leave_threshold, N=7; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3046o; actual=0; do x=1 to 100; if x>7 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3046o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3046 rows=' rows;
else do; set b3046o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND7_PASS=B3046';
else put 'ERROR: ROUND7_FAIL=B3046 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3046:; quit;
