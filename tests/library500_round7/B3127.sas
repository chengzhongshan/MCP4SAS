/* B3127 update_multiple_transactions, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3127a; do k=1 to 8; x=10*k; y=20*k; output; end; run;
data b3127b; do k=1 to 8; x=.; y=8; output; x=9; y=.; output; end; run;
data b3127c; update b3127a b3127b; by k; run;
proc sql; create table b3127o as select sum(x+y) as actual from b3127c; quit;

data _null_; if 0 then set b3127o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3127 rows=' rows;
else do; set b3127o; if not missing(actual) and abs(actual-(136))<=1e-9*max(1,abs(136)) then put 'ROUND7_PASS=B3127';
else put 'ERROR: ROUND7_FAIL=B3127 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3127:; quit;
