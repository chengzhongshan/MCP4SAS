/* H2514 hash_multidata_next, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2514a; do k=1 to 5; value=k; output; value=k+10; output; end; run;
data h2514o; if 0 then set h2514a; declare hash h(dataset:'h2514a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 5; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2514o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2514 rows=' rows;
else do; set h2514o; if not missing(actual) and abs(actual-(80))<=1e-9*max(1,abs(80)) then put 'ROUND6_PASS=H2514';
else put 'ERROR: ROUND6_FAIL=H2514 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2514:; quit;
