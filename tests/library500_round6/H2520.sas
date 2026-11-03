/* H2520 hash_multidata_next, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2520a; do k=1 to 11; value=k; output; value=k+10; output; end; run;
data h2520o; if 0 then set h2520a; declare hash h(dataset:'h2520a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 11; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2520o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2520 rows=' rows;
else do; set h2520o; if not missing(actual) and abs(actual-(242))<=1e-9*max(1,abs(242)) then put 'ROUND6_PASS=H2520';
else put 'ERROR: ROUND6_FAIL=H2520 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2520:; quit;
