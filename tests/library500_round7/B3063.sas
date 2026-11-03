/* B3063 do_list_and_range, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3063a; do x=1 to 4,2*4; output; end; run;
proc sql; create table b3063o as select sum(x) as actual from b3063a; quit;

data _null_; if 0 then set b3063o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3063 rows=' rows;
else do; set b3063o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND7_PASS=B3063';
else put 'ERROR: ROUND7_FAIL=B3063 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3063:; quit;
