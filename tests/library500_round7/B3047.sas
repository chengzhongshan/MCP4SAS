/* B3047 do_leave_threshold, N=8; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3047o; actual=0; do x=1 to 100; if x>8 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3047o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3047 rows=' rows;
else do; set b3047o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND7_PASS=B3047';
else put 'ERROR: ROUND7_FAIL=B3047 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3047:; quit;
