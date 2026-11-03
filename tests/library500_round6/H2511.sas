/* H2511 hash_multidata_next, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2511a; do k=1 to 2; value=k; output; value=k+10; output; end; run;
data h2511o; if 0 then set h2511a; declare hash h(dataset:'h2511a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 2; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2511o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2511 rows=' rows;
else do; set h2511o; if not missing(actual) and abs(actual-(26))<=1e-9*max(1,abs(26)) then put 'ROUND6_PASS=H2511';
else put 'ERROR: ROUND6_FAIL=H2511 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2511:; quit;
