/* H2587 hash_duplicate_replace_policy, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2587a; k=1; value=8; output; value=9; output; run;
data h2587o; if 0 then set h2587a; declare hash h(dataset:'h2587a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2587o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2587 rows=' rows;
else do; set h2587o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2587';
else put 'ERROR: ROUND6_FAIL=H2587 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2587:; quit;
