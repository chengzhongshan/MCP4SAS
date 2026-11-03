/* H2593 hash_explicit_key_argument, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2593a; do k=1 to 4; value=2*k; output; end; run;
data h2593o; if 0 then set h2593a; declare hash h(dataset:'h2593a'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do j=1 to 4; rc=h.find(key:j); if rc=0 then actual=actual+value; end; output; stop; run;

data _null_; if 0 then set h2593o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2593 rows=' rows;
else do; set h2593o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND6_PASS=H2593';
else put 'ERROR: ROUND6_FAIL=H2593 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2593:; quit;
