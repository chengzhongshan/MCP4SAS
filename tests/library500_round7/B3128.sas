/* B3128 update_multiple_transactions, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3128a; do k=1 to 9; x=10*k; y=20*k; output; end; run;
data b3128b; do k=1 to 9; x=.; y=9; output; x=10; y=.; output; end; run;
data b3128c; update b3128a b3128b; by k; run;
proc sql; create table b3128o as select sum(x+y) as actual from b3128c; quit;

data _null_; if 0 then set b3128o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3128 rows=' rows;
else do; set b3128o; if not missing(actual) and abs(actual-(171))<=1e-9*max(1,abs(171)) then put 'ROUND7_PASS=B3128';
else put 'ERROR: ROUND7_FAIL=B3128 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3128:; quit;
