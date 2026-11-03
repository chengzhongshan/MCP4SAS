/* H2951 failure_hash_duplicate_error, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2951a; do k=1 to 2; value=k; output; output; end; run;
data h2951b; if 0 then set h2951a; declare hash h(dataset:'h2951a',duplicate:'error'); h.definekey('k'); h.definedata('value'); h.definedone(); stop; run;

proc datasets library=work nolist; delete h2951:; quit;
