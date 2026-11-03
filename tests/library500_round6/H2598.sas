/* H2598 hash_explicit_key_argument, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2598a; do k=1 to 9; value=2*k; output; end; run;
data h2598o; if 0 then set h2598a; declare hash h(dataset:'h2598a'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do j=1 to 9; rc=h.find(key:j); if rc=0 then actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2598o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2598 rows=' rows;
else do; set h2598o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND6_PASS=H2598';
else put 'ERROR: ROUND6_FAIL=H2598 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2598:; quit;
