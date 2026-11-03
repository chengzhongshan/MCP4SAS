/* B3044 do_leave_threshold, N=5; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3044o; actual=0; do x=1 to 100; if x>5 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3044o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3044 rows=' rows;
else do; set b3044o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3044';
else put 'ERROR: ROUND7_FAIL=B3044 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3044:; quit;
