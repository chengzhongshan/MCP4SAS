/* H2583 hash_duplicate_replace_policy, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2583a; k=1; value=4; output; value=5; output; run;
data h2583o; if 0 then set h2583a; declare hash h(dataset:'h2583a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2583o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2583 rows=' rows;
else do; set h2583o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2583';
else put 'ERROR: ROUND6_FAIL=H2583 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2583:; quit;
