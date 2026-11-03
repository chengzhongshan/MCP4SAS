/* H2562 hash_clear_all, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2562o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 3; rc=h.add(); end; before=h.num_items; rc=h.clear(); actual=before+(h.num_items=0); output; stop; run;

data _null_; if 0 then set h2562o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2562 rows=' rows;
else do; set h2562o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2562';
else put 'ERROR: ROUND6_FAIL=H2562 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2562:; quit;
