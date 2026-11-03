/* B3123 update_multiple_transactions, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3123a; do k=1 to 4; x=10*k; y=20*k; output; end; run;
data b3123b; do k=1 to 4; x=.; y=4; output; x=5; y=.; output; end; run;
data b3123c; update b3123a b3123b; by k; run;
proc sql; create table b3123o as select sum(x+y) as actual from b3123c; quit;

data _null_; if 0 then set b3123o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3123 rows=' rows;
else do; set b3123o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND7_PASS=B3123';
else put 'ERROR: ROUND7_FAIL=B3123 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3123:; quit;
