/* H2508 hash_missing_key_clear, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2508a; do k=1 to 9; value=k; output; end; run;
data h2508o; if 0 then set h2508a; declare hash h(dataset:'h2508a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=10; call missing(value); rc=h.find(); actual=9+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2508o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2508 rows=' rows;
else do; set h2508o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2508';
else put 'ERROR: ROUND6_FAIL=H2508 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2508:; quit;
