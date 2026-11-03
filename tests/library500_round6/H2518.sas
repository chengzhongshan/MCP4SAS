/* H2518 hash_multidata_next, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2518a; do k=1 to 9; value=k; output; value=k+10; output; end; run;
data h2518o; if 0 then set h2518a; declare hash h(dataset:'h2518a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 9; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2518o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2518 rows=' rows;
else do; set h2518o; if not missing(actual) and abs(actual-(180))<=1e-9*max(1,abs(180)) then put 'ROUND6_PASS=H2518';
else put 'ERROR: ROUND6_FAIL=H2518 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2518:; quit;
