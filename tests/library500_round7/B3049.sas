/* B3049 do_leave_threshold, N=10; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3049o; actual=0; do x=1 to 100; if x>10 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3049o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3049 rows=' rows;
else do; set b3049o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND7_PASS=B3049';
else put 'ERROR: ROUND7_FAIL=B3049 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3049:; quit;
