/* H2543 hash_replace_items, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2543o; length k value 8; declare hash h(); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 4; value=k; rc=h.add(); value=3*k; rc=h.replace(); end;
actual=h.num_items; do k=1 to 4; rc=h.find(); actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2543o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2543 rows=' rows;
else do; set h2543o; if not missing(actual) and abs(actual-(34))<=1e-9*max(1,abs(34)) then put 'ROUND6_PASS=H2543';
else put 'ERROR: ROUND6_FAIL=H2543 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2543:; quit;
