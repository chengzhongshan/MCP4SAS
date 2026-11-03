/* H2581 hash_duplicate_replace_policy, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2581a; k=1; value=2; output; value=3; output; run;
data h2581o; if 0 then set h2581a; declare hash h(dataset:'h2581a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2581o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2581 rows=' rows;
else do; set h2581o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2581';
else put 'ERROR: ROUND6_FAIL=H2581 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2581:; quit;
