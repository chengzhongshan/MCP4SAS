/* H2554 hash_remove_entries, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2554o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 5; rc=h.add(); end; do k=2 to 5 by 2; rc=h.remove(); end;
k=2; rc=h.find(); actual=h.num_items+5*(rc ne 0); output; stop; run;

data _null_; if 0 then set h2554o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2554 rows=' rows;
else do; set h2554o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2554';
else put 'ERROR: ROUND6_FAIL=H2554 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2554:; quit;
