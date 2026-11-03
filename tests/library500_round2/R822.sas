/* R822 hash_lookup, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r822a; do k=1 to 3; value=3*k; output; end; run;
data r822b; if 0 then set r822a; declare hash h(dataset:'r822a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 3; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r822o as select sum(value) as actual from r822b; quit;

data _null_; if 0 then set r822o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R822 rows=' rows;
else do; set r822o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND2_PASS=R822';
else put 'ERROR: ROUND2_FAIL=R822 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r822:; quit;
