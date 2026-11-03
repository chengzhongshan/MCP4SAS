/* H2952 failure_hash_duplicate_error, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2952a; do k=1 to 3; value=k; output; output; end; run;
data h2952b; if 0 then set h2952a; declare hash h(dataset:'h2952a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2952:; quit;
