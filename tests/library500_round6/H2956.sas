/* H2956 failure_hash_duplicate_error, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2956a; do k=1 to 7; value=k; output; output; end; run;
data h2956b; if 0 then set h2956a; declare hash h(dataset:'h2956a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2956:; quit;
