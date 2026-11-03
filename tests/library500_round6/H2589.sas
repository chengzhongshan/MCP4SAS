/* H2589 hash_duplicate_replace_policy, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2589a; k=1; value=10; output; value=11; output; run;
data h2589o; if 0 then set h2589a; declare hash h(dataset:'h2589a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2589o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2589 rows=' rows;
else do; set h2589o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2589';
else put 'ERROR: ROUND6_FAIL=H2589 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2589:; quit;
