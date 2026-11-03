/* H2501 hash_missing_key_clear, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2501a; do k=1 to 2; value=k; output; end; run;
data h2501o; if 0 then set h2501a; declare hash h(dataset:'h2501a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=3; call missing(value); rc=h.find(); actual=2+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2501o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2501 rows=' rows;
else do; set h2501o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2501';
else put 'ERROR: ROUND6_FAIL=H2501 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2501:; quit;
