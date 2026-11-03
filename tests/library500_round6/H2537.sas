/* H2537 hash_iterator_descending, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2537a; do k=1 to 8; output; end; run;
data h2537o; if 0 then set h2537a; declare hash h(dataset:'h2537a',ordered:'d'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2537o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2537 rows=' rows;
else do; set h2537o; if not missing(actual) and abs(actual-(120))<=1e-9*max(1,abs(120)) then put 'ROUND6_PASS=H2537';
else put 'ERROR: ROUND6_FAIL=H2537 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2537:; quit;
