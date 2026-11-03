/* B3129 update_multiple_transactions, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3129a; do k=1 to 10; x=10*k; y=20*k; output; end; run;
data b3129b; do k=1 to 10; x=.; y=10; output; x=11; y=.; output; end; run;
data b3129c; update b3129a b3129b; by k; run;
proc sql; create table b3129o as select sum(x+y) as actual from b3129c; quit;

data _null_; if 0 then set b3129o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3129 rows=' rows;
else do; set b3129o; if not missing(actual) and abs(actual-(210))<=1e-9*max(1,abs(210)) then put 'ROUND7_PASS=B3129';
else put 'ERROR: ROUND7_FAIL=B3129 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3129:; quit;
