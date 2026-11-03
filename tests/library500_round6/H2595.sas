/* H2595 hash_explicit_key_argument, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2595a; do k=1 to 6; value=2*k; output; end; run;
data h2595o; if 0 then set h2595a; declare hash h(dataset:'h2595a'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do j=1 to 6; rc=h.find(key:j); if rc=0 then actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2595o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2595 rows=' rows;
else do; set h2595o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND6_PASS=H2595';
else put 'ERROR: ROUND6_FAIL=H2595 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2595:; quit;
