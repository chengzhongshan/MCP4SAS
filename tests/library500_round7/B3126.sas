/* B3126 update_multiple_transactions, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3126a; do k=1 to 7; x=10*k; y=20*k; output; end; run;
data b3126b; do k=1 to 7; x=.; y=7; output; x=8; y=.; output; end; run;
data b3126c; update b3126a b3126b; by k; run;
proc sql; create table b3126o as select sum(x+y) as actual from b3126c; quit;

data _null_; if 0 then set b3126o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3126 rows=' rows;
else do; set b3126o; if not missing(actual) and abs(actual-(105))<=1e-9*max(1,abs(105)) then put 'ROUND7_PASS=B3126';
else put 'ERROR: ROUND7_FAIL=B3126 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3126:; quit;
