/* H2517 hash_multidata_next, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2517a; do k=1 to 8; value=k; output; value=k+10; output; end; run;
data h2517o; if 0 then set h2517a; declare hash h(dataset:'h2517a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 8; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2517o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2517 rows=' rows;
else do; set h2517o; if not missing(actual) and abs(actual-(152))<=1e-9*max(1,abs(152)) then put 'ROUND6_PASS=H2517';
else put 'ERROR: ROUND6_FAIL=H2517 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2517:; quit;
