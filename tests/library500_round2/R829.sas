/* R829 hash_lookup, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r829a; do k=1 to 10; value=3*k; output; end; run;
data r829b; if 0 then set r829a; declare hash h(dataset:'r829a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 10; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r829o as select sum(value) as actual from r829b; quit;

data _null_; if 0 then set r829o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R829 rows=' rows;
else do; set r829o; if not missing(actual) and abs(actual-(165))<=1e-10*max(1,abs(165)) then put 'ROUND2_PASS=R829';
else put 'ERROR: ROUND2_FAIL=R829 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r829:; quit;
