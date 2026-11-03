/* H2504 hash_missing_key_clear, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2504a; do k=1 to 5; value=k; output; end; run;
data h2504o; if 0 then set h2504a; declare hash h(dataset:'h2504a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=6; call missing(value); rc=h.find(); actual=5+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2504o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2504 rows=' rows;
else do; set h2504o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2504';
else put 'ERROR: ROUND6_FAIL=H2504 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2504:; quit;
