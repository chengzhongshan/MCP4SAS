/* B3068 do_list_and_range, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3068a; do x=1 to 9,2*9; output; end; run;
proc sql; create table b3068o as select sum(x) as actual from b3068a; quit;

data _null_; if 0 then set b3068o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3068 rows=' rows;
else do; set b3068o; if not missing(actual) and abs(actual-(63))<=1e-9*max(1,abs(63)) then put 'ROUND7_PASS=B3068';
else put 'ERROR: ROUND7_FAIL=B3068 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3068:; quit;
