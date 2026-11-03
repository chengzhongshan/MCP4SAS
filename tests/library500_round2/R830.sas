/* R830 hash_lookup, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r830a; do k=1 to 11; value=3*k; output; end; run;
data r830b; if 0 then set r830a; declare hash h(dataset:'r830a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 11; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r830o as select sum(value) as actual from r830b; quit;

data _null_; if 0 then set r830o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R830 rows=' rows;
else do; set r830o; if not missing(actual) and abs(actual-(198))<=1e-10*max(1,abs(198)) then put 'ROUND2_PASS=R830';
else put 'ERROR: ROUND2_FAIL=R830 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r830:; quit;
