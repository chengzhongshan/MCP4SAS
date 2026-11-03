/* H2513 hash_multidata_next, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2513a; do k=1 to 4; value=k; output; value=k+10; output; end; run;
data h2513o; if 0 then set h2513a; declare hash h(dataset:'h2513a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 4; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2513o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2513 rows=' rows;
else do; set h2513o; if not missing(actual) and abs(actual-(60))<=1e-9*max(1,abs(60)) then put 'ROUND6_PASS=H2513';
else put 'ERROR: ROUND6_FAIL=H2513 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2513:; quit;
