/* H2590 hash_duplicate_replace_policy, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2590a; k=1; value=11; output; value=12; output; run;
data h2590o; if 0 then set h2590a; declare hash h(dataset:'h2590a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2590o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2590 rows=' rows;
else do; set h2590o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2590';
else put 'ERROR: ROUND6_FAIL=H2590 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2590:; quit;
