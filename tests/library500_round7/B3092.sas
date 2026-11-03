/* B3092 multiple_set_shorter_stream, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3092a; do x=1 to 3+2; output; end; run;
data b3092b; do y=1 to 3; output; end; run;
data b3092c; set b3092a; set b3092b; value=x+y; run;
proc sql; create table b3092o as select sum(value) as actual from b3092c; quit;

data _null_; if 0 then set b3092o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3092 rows=' rows;
else do; set b3092o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3092';
else put 'ERROR: ROUND7_FAIL=B3092 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3092:; quit;
