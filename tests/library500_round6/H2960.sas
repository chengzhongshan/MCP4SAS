/* H2960 failure_hash_duplicate_error, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2960a; do k=1 to 11; value=k; output; output; end; run;
data h2960b; if 0 then set h2960a; declare hash h(dataset:'h2960a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2960:; quit;
