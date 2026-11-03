/* H2551 hash_remove_entries, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2551o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 2; rc=h.add(); end; do k=2 to 2 by 2; rc=h.remove(); end;
k=2; rc=h.find(); actual=h.num_items+2*(rc ne 0); output; stop; run;

data _null_; if 0 then set h2551o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2551 rows=' rows;
else do; set h2551o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2551';
else put 'ERROR: ROUND6_FAIL=H2551 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2551:; quit;
