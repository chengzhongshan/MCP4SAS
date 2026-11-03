/* B3122 update_multiple_transactions, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3122a; do k=1 to 3; x=10*k; y=20*k; output; end; run;
data b3122b; do k=1 to 3; x=.; y=3; output; x=4; y=.; output; end; run;
data b3122c; update b3122a b3122b; by k; run;
proc sql; create table b3122o as select sum(x+y) as actual from b3122c; quit;

data _null_; if 0 then set b3122o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3122 rows=' rows;
else do; set b3122o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3122';
else put 'ERROR: ROUND7_FAIL=B3122 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3122:; quit;
