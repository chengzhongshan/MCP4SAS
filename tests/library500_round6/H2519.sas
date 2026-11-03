/* H2519 hash_multidata_next, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2519a; do k=1 to 10; value=k; output; value=k+10; output; end; run;
data h2519o; if 0 then set h2519a; declare hash h(dataset:'h2519a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 10; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2519o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2519 rows=' rows;
else do; set h2519o; if not missing(actual) and abs(actual-(210))<=1e-9*max(1,abs(210)) then put 'ROUND6_PASS=H2519';
else put 'ERROR: ROUND6_FAIL=H2519 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2519:; quit;
