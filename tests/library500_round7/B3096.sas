/* B3096 multiple_set_shorter_stream, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3096a; do x=1 to 7+2; output; end; run;
data b3096b; do y=1 to 7; output; end; run;
data b3096c; set b3096a; set b3096b; value=x+y; run;
proc sql; create table b3096o as select sum(value) as actual from b3096c; quit;

data _null_; if 0 then set b3096o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3096 rows=' rows;
else do; set b3096o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND7_PASS=B3096';
else put 'ERROR: ROUND7_FAIL=B3096 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3096:; quit;
