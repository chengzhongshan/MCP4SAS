/* B3066 do_list_and_range, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3066a; do x=1 to 7,2*7; output; end; run;
proc sql; create table b3066o as select sum(x) as actual from b3066a; quit;

data _null_; if 0 then set b3066o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3066 rows=' rows;
else do; set b3066o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND7_PASS=B3066';
else put 'ERROR: ROUND7_FAIL=B3066 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3066:; quit;
