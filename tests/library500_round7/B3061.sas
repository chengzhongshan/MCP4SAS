/* B3061 do_list_and_range, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3061a; do x=1 to 2,2*2; output; end; run;
proc sql; create table b3061o as select sum(x) as actual from b3061a; quit;

data _null_; if 0 then set b3061o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3061 rows=' rows;
else do; set b3061o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3061';
else put 'ERROR: ROUND7_FAIL=B3061 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3061:; quit;
