/* H2592 hash_explicit_key_argument, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2592a; do k=1 to 3; value=2*k; output; end; run;
data h2592o; if 0 then set h2592a; declare hash h(dataset:'h2592a'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do j=1 to 3; rc=h.find(key:j); if rc=0 then actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2592o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2592 rows=' rows;
else do; set h2592o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2592';
else put 'ERROR: ROUND6_FAIL=H2592 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2592:; quit;
