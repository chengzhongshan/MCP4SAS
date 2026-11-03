/* H2510 hash_missing_key_clear, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2510a; do k=1 to 11; value=k; output; end; run;
data h2510o; if 0 then set h2510a; declare hash h(dataset:'h2510a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=12; call missing(value); rc=h.find(); actual=11+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2510o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2510 rows=' rows;
else do; set h2510o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2510';
else put 'ERROR: ROUND6_FAIL=H2510 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2510:; quit;
