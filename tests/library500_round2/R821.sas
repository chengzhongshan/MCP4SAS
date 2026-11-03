/* R821 hash_lookup, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r821a; do k=1 to 2; value=3*k; output; end; run;
data r821b; if 0 then set r821a; declare hash h(dataset:'r821a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 2; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r821o as select sum(value) as actual from r821b; quit;

data _null_; if 0 then set r821o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R821 rows=' rows;
else do; set r821o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R821';
else put 'ERROR: ROUND2_FAIL=R821 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r821:; quit;
