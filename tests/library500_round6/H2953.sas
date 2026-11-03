/* H2953 failure_hash_duplicate_error, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2953a; do k=1 to 4; value=k; output; output; end; run;
data h2953b; if 0 then set h2953a; declare hash h(dataset:'h2953a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2953:; quit;
