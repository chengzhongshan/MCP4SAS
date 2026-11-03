/* B3130 update_multiple_transactions, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:3498 */

data b3130a; do k=1 to 11; x=10*k; y=20*k; output; end; run;
data b3130b; do k=1 to 11; x=.; y=11; output; x=12; y=.; output; end; run;
data b3130c; update b3130a b3130b; by k; run;
proc sql; create table b3130o as select sum(x+y) as actual from b3130c; quit;

data _null_; if 0 then set b3130o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3130 rows=' rows;
else do; set b3130o; if not missing(actual) and abs(actual-(253))<=1e-9*max(1,abs(253)) then put 'ROUND7_PASS=B3130';
else put 'ERROR: ROUND7_FAIL=B3130 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3130:; quit;
