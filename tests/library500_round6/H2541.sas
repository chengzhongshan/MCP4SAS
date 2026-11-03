/* H2541 hash_replace_items, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2541o; length k value 8; declare hash h(); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 2; value=k; rc=h.add(); value=3*k; rc=h.replace(); end;
actual=h.num_items; do k=1 to 2; rc=h.find(); actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2541o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2541 rows=' rows;
else do; set h2541o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2541';
else put 'ERROR: ROUND6_FAIL=H2541 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2541:; quit;
