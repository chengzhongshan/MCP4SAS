/* B3062 do_list_and_range, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3062a; do x=1 to 3,2*3; output; end; run;
proc sql; create table b3062o as select sum(x) as actual from b3062a; quit;

data _null_; if 0 then set b3062o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3062 rows=' rows;
else do; set b3062o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3062';
else put 'ERROR: ROUND7_FAIL=B3062 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3062:; quit;
