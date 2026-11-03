/* B3065 do_list_and_range, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3065a; do x=1 to 6,2*6; output; end; run;
proc sql; create table b3065o as select sum(x) as actual from b3065a; quit;

data _null_; if 0 then set b3065o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3065 rows=' rows;
else do; set b3065o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND7_PASS=B3065';
else put 'ERROR: ROUND7_FAIL=B3065 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3065:; quit;
