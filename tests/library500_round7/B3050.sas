/* B3050 do_leave_threshold, N=11; source: Cody's Data Cleaning Techniques Using SAS Software.txt:2782 */

data b3050o; actual=0; do x=1 to 100; if x>11 then leave; actual=actual+x; end; run;

data _null_; if 0 then set b3050o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3050 rows=' rows;
else do; set b3050o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND7_PASS=B3050';
else put 'ERROR: ROUND7_FAIL=B3050 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3050:; quit;
