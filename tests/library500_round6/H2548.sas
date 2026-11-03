/* H2548 hash_replace_items, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2548o; length k value 8; declare hash h(); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 9; value=k; rc=h.add(); value=3*k; rc=h.replace(); end;
actual=h.num_items; do k=1 to 9; rc=h.find(); actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2548o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2548 rows=' rows;
else do; set h2548o; if not missing(actual) and abs(actual-(144))<=1e-9*max(1,abs(144)) then put 'ROUND6_PASS=H2548';
else put 'ERROR: ROUND6_FAIL=H2548 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2548:; quit;
