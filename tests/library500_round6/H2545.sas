/* H2545 hash_replace_items, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2545o; length k value 8; declare hash h(); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 6; value=k; rc=h.add(); value=3*k; rc=h.replace(); end;
actual=h.num_items; do k=1 to 6; rc=h.find(); actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2545o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2545 rows=' rows;
else do; set h2545o; if not missing(actual) and abs(actual-(69))<=1e-9*max(1,abs(69)) then put 'ROUND6_PASS=H2545';
else put 'ERROR: ROUND6_FAIL=H2545 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2545:; quit;
