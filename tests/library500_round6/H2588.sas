/* H2588 hash_duplicate_replace_policy, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2588a; k=1; value=9; output; value=10; output; run;
data h2588o; if 0 then set h2588a; declare hash h(dataset:'h2588a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2588o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2588 rows=' rows;
else do; set h2588o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2588';
else put 'ERROR: ROUND6_FAIL=H2588 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2588:; quit;
