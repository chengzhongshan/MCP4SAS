/* H2505 hash_missing_key_clear, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2505a; do k=1 to 6; value=k; output; end; run;
data h2505o; if 0 then set h2505a; declare hash h(dataset:'h2505a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=7; call missing(value); rc=h.find(); actual=6+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2505o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2505 rows=' rows;
else do; set h2505o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2505';
else put 'ERROR: ROUND6_FAIL=H2505 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2505:; quit;
