/* B3095 multiple_set_shorter_stream, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3095a; do x=1 to 6+2; output; end; run;
data b3095b; do y=1 to 6; output; end; run;
data b3095c; set b3095a; set b3095b; value=x+y; run;
proc sql; create table b3095o as select sum(value) as actual from b3095c; quit;

data _null_; if 0 then set b3095o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3095 rows=' rows;
else do; set b3095o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND7_PASS=B3095';
else put 'ERROR: ROUND7_FAIL=B3095 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3095:; quit;
