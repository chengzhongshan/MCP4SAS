/* H2597 hash_explicit_key_argument, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2597a; do k=1 to 8; value=2*k; output; end; run;
data h2597o; if 0 then set h2597a; declare hash h(dataset:'h2597a'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do j=1 to 8; rc=h.find(key:j); if rc=0 then actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2597o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2597 rows=' rows;
else do; set h2597o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND6_PASS=H2597';
else put 'ERROR: ROUND6_FAIL=H2597 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2597:; quit;
