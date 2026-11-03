/* H2506 hash_missing_key_clear, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2506a; do k=1 to 7; value=k; output; end; run;
data h2506o; if 0 then set h2506a; declare hash h(dataset:'h2506a'); h.definekey('k'); h.definedata('value'); h.definedone();
k=8; call missing(value); rc=h.find(); actual=7+(rc ne 0)+missing(value); output; stop; run;

data _null_; if 0 then set h2506o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2506 rows=' rows;
else do; set h2506o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2506';
else put 'ERROR: ROUND6_FAIL=H2506 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2506:; quit;
