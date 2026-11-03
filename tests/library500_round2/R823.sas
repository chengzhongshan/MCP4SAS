/* R823 hash_lookup, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r823a; do k=1 to 4; value=3*k; output; end; run;
data r823b; if 0 then set r823a; declare hash h(dataset:'r823a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 4; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r823o as select sum(value) as actual from r823b; quit;

data _null_; if 0 then set r823o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R823 rows=' rows;
else do; set r823o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND2_PASS=R823';
else put 'ERROR: ROUND2_FAIL=R823 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r823:; quit;
