/* H2509 hash_missing_key_clear, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2509a; do k=1 to 10; value=k; output; end; run;
data h2509o; if 0 then set h2509a; declare hash h(dataset:'h2509a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=11; call missing(value); rc=h.find(); actual=10+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2509o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2509 rows=' rows;
else do; set h2509o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2509';
else put 'ERROR: ROUND6_FAIL=H2509 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2509:; quit;
