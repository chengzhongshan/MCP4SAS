/* H2586 hash_duplicate_replace_policy, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2586a; k=1; value=7; output; value=8; output; run;
data h2586o; if 0 then set h2586a; declare hash h(dataset:'h2586a',duplicate:'replace'); h.definekey('k'); h.definedata('value'); h.definedone();
k=1; rc=h.find(); actual=value+h.num_items; output; stop; run;

data _null_; if 0 then set h2586o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2586 rows=' rows;
else do; set h2586o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2586';
else put 'ERROR: ROUND6_FAIL=H2586 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2586:; quit;
