/* R824 hash_lookup, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data r824a; do k=1 to 5; value=3*k; output; end; run;
data r824b; if 0 then set r824a; declare hash h(dataset:'r824a'); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 5; rc=h.find(); if rc=0 then output; end; stop; run;
proc sql; create table r824o as select sum(value) as actual from r824b; quit;

data _null_; if 0 then set r824o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R824 rows=' rows;
else do; set r824o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R824';
else put 'ERROR: ROUND2_FAIL=R824 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r824:; quit;
