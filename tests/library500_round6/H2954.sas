/* H2954 failure_hash_duplicate_error, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2954a; do k=1 to 5; value=k; output; output; end; run;
data h2954b; if 0 then set h2954a; declare hash h(dataset:'h2954a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2954:; quit;
