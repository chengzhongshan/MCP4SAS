/* H2585 hash_duplicate_replace_policy, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2585a; k=1; value=6; output; value=7; output; run;
data h2585o; if 0 then set h2585a; declare hash h(dataset:'h2585a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2585o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2585 rows=' rows;
else do; set h2585o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2585';
else put 'ERROR: ROUND6_FAIL=H2585 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2585:; quit;
