/* B3124 update_multiple_transactions, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3124a; do k=1 to 5; x=10*k; y=20*k; output; end; run;
data b3124b; do k=1 to 5; x=.; y=5; output; x=6; y=.; output; end; run;
data b3124c; update b3124a b3124b; by k; run;
proc sql; create table b3124o as select sum(x+y) as actual from b3124c; quit;

data _null_; if 0 then set b3124o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3124 rows=' rows;
else do; set b3124o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND7_PASS=B3124';
else put 'ERROR: ROUND7_FAIL=B3124 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3124:; quit;
