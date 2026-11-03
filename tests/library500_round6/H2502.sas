/* H2502 hash_missing_key_clear, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2502a; do k=1 to 3; value=k; output; end; run;
data h2502o; if 0 then set h2502a; declare hash h(dataset:'h2502a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=4; call missing(value); rc=h.find(); actual=3+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2502o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2502 rows=' rows;
else do; set h2502o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2502';
else put 'ERROR: ROUND6_FAIL=H2502 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2502:; quit;
