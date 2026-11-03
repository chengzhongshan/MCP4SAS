/* H2503 hash_missing_key_clear, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2503a; do k=1 to 4; value=k; output; end; run;
data h2503o; if 0 then set h2503a; declare hash h(dataset:'h2503a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=5; call missing(value); rc=h.find(); actual=4+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2503o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2503 rows=' rows;
else do; set h2503o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2503';
else put 'ERROR: ROUND6_FAIL=H2503 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2503:; quit;
