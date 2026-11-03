/* B3070 do_list_and_range, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:666 */

data b3070a; do x=1 to 11,2*11; output; end; run;
proc sql; create table b3070o as select sum(x) as actual from b3070a; quit;

data _null_; if 0 then set b3070o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3070 rows=' rows;
else do; set b3070o; if not missing(actual) and abs(actual-(88))<=1e-9*max(1,abs(88)) then put 'ROUND7_PASS=B3070';
else put 'ERROR: ROUND7_FAIL=B3070 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3070:; quit;
