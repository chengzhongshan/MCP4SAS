/* H2582 hash_duplicate_replace_policy, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2582a; k=1; value=3; output; value=4; output; run;
data h2582o; if 0 then set h2582a; declare hash h(dataset:'h2582a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2582o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2582 rows=' rows;
else do; set h2582o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2582';
else put 'ERROR: ROUND6_FAIL=H2582 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2582:; quit;
