/* B3121 update_multiple_transactions, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3121a; do k=1 to 2; x=10*k; y=20*k; output; end; run;
data b3121b; do k=1 to 2; x=.; y=2; output; x=3; y=.; output; end; run;
data b3121c; update b3121a b3121b; by k; run;
proc sql; create table b3121o as select sum(x+y) as actual from b3121c; quit;

data _null_; if 0 then set b3121o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3121 rows=' rows;
else do; set b3121o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND7_PASS=B3121';
else put 'ERROR: ROUND7_FAIL=B3121 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3121:; quit;
