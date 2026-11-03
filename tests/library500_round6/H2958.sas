/* H2958 failure_hash_duplicate_error, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2958a; do k=1 to 9; value=k; output; output; end; run;
data h2958b; if 0 then set h2958a; declare hash h(dataset:'h2958a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2958:; quit;
