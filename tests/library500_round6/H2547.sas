/* H2547 hash_replace_items, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2547o; length k value 8; declare hash h(); h.definekey('k'); h.definedata('value'); h.definedone();
do k=1 to 8; value=k; rc=h.add(); value=3*k; rc=h.replace(); end;
actual=h.num_items; do k=1 to 8; rc=h.find(); actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2547o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2547 rows=' rows;
else do; set h2547o; if not missing(actual) and abs(actual-(116))<=1e-9*max(1,abs(116)) then put 'ROUND6_PASS=H2547';
else put 'ERROR: ROUND6_FAIL=H2547 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2547:; quit;
