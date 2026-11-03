/* H2556 hash_remove_entries, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2556o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 7; rc=h.add(); end; do k=2 to 7 by 2; rc=h.remove(); end;
k=2; rc=h.find(); actual=h.num_items+7*(rc ne 0); output; stop; run;

data _null_; if 0 then set h2556o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2556 rows=' rows;
else do; set h2556o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2556';
else put 'ERROR: ROUND6_FAIL=H2556 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2556:; quit;
