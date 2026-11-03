/* B3067 do_list_and_range, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3067a; do x=1 to 8,2*8; output; end; run;
proc sql; create table b3067o as select sum(x) as actual from b3067a; quit;

data _null_; if 0 then set b3067o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3067 rows=' rows;
else do; set b3067o; if not missing(actual) and abs(actual-(52))<=1e-9*max(1,abs(52)) then put 'ROUND7_PASS=B3067';
else put 'ERROR: ROUND7_FAIL=B3067 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3067:; quit;
