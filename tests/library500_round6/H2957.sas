/* H2957 failure_hash_duplicate_error, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2957a; do k=1 to 8; value=k; output; output; end; run;
data h2957b; if 0 then set h2957a; declare hash h(dataset:'h2957a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2957:; quit;
