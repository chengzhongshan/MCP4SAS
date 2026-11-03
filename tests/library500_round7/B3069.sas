/* B3069 do_list_and_range, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3069a; do x=1 to 10,2*10; output; end; run;
proc sql; create table b3069o as select sum(x) as actual from b3069a; quit;

data _null_; if 0 then set b3069o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3069 rows=' rows;
else do; set b3069o; if not missing(actual) and abs(actual-(75))<=1e-9*max(1,abs(75)) then put 'ROUND7_PASS=B3069';
else put 'ERROR: ROUND7_FAIL=B3069 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3069:; quit;
