/* R827 hash_lookup, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r827a; do k=1 to 8; value=3*k; output; end; run;
data r827b; if 0 then set r827a; declare hash h(dataset:'r827a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 8; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r827o as select sum(value) as actual from r827b; quit;

data _null_; if 0 then set r827o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R827 rows=' rows;
else do; set r827o; if not missing(actual) and abs(actual-(108))<=1e-10*max(1,abs(108)) then put 'ROUND2_PASS=R827';
else put 'ERROR: ROUND2_FAIL=R827 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r827:; quit;
