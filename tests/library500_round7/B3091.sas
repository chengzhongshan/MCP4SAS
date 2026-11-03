/* B3091 multiple_set_shorter_stream, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3091a; do x=1 to 2+2; output; end; run;
data b3091b; do y=1 to 2; output; end; run;
data b3091c; set b3091a; set b3091b; value=x+y; run;
proc sql; create table b3091o as select sum(value) as actual from b3091c; quit;

data _null_; if 0 then set b3091o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3091 rows=' rows;
else do; set b3091o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3091';
else put 'ERROR: ROUND7_FAIL=B3091 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3091:; quit;
