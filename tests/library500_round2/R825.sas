/* R825 hash_lookup, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r825a; do k=1 to 6; value=3*k; output; end; run;
data r825b; if 0 then set r825a; declare hash h(dataset:'r825a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 6; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r825o as select sum(value) as actual from r825b; quit;

data _null_; if 0 then set r825o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R825 rows=' rows;
else do; set r825o; if not missing(actual) and abs(actual-(63))<=1e-10*max(1,abs(63)) then put 'ROUND2_PASS=R825';
else put 'ERROR: ROUND2_FAIL=R825 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r825:; quit;
