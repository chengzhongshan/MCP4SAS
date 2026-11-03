/* B3099 multiple_set_shorter_stream, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3099a; do x=1 to 10+2; output; end; run;
data b3099b; do y=1 to 10; output; end; run;
data b3099c; set b3099a; set b3099b; value=x+y; run;
proc sql; create table b3099o as select sum(value) as actual from b3099c; quit;

data _null_; if 0 then set b3099o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3099 rows=' rows;
else do; set b3099o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND7_PASS=B3099';
else put 'ERROR: ROUND7_FAIL=B3099 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3099:; quit;
