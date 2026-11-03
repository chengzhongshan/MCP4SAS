/* R828 hash_lookup, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r828a; do k=1 to 9; value=3*k; output; end; run;
data r828b; if 0 then set r828a; declare hash h(dataset:'r828a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 9; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r828o as select sum(value) as actual from r828b; quit;

data _null_; if 0 then set r828o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R828 rows=' rows;
else do; set r828o; if not missing(actual) and abs(actual-(135))<=1e-10*max(1,abs(135)) then put 'ROUND2_PASS=R828';
else put 'ERROR: ROUND2_FAIL=R828 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r828:; quit;
