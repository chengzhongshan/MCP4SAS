/* H2584 hash_duplicate_replace_policy, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2584a; k=1; value=5; output; value=6; output; run;
data h2584o; if 0 then set h2584a; declare hash h(dataset:'h2584a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2584o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2584 rows=' rows;
else do; set h2584o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2584';
else put 'ERROR: ROUND6_FAIL=H2584 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2584:; quit;
