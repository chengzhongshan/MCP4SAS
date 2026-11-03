/* H2955 failure_hash_duplicate_error, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2955a; do k=1 to 6; value=k; output; output; end; run;
data h2955b; if 0 then set h2955a; declare hash h(dataset:'h2955a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2955:; quit;
