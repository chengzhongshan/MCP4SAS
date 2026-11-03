/* H2507 hash_missing_key_clear, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2507a; do k=1 to 8; value=k; output; end; run;
data h2507o; if 0 then set h2507a; declare hash h(dataset:'h2507a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=9; call missing(value); rc=h.find(); actual=8+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2507o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2507 rows=' rows;
else do; set h2507o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2507';
else put 'ERROR: ROUND6_FAIL=H2507 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2507:; quit;
