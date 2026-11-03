/* R826 hash_lookup, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r826a; do k=1 to 7; value=3*k; output; end; run;
data r826b; if 0 then set r826a; declare hash h(dataset:'r826a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 7; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r826o as select sum(value) as actual from r826b; quit;

data _null_; if 0 then set r826o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R826 rows=' rows;
else do; set r826o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND2_PASS=R826';
else put 'ERROR: ROUND2_FAIL=R826 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r826:; quit;
