/* H2959 failure_hash_duplicate_error, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2959a; do k=1 to 10; value=k; output; output; end; run;
data h2959b; if 0 then set h2959a; declare hash h(dataset:'h2959a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2959:; quit;
