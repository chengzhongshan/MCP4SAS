/* H2534 hash_iterator_descending, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2534a; do k=1 to 5; output; end; run;
data h2534o; if 0 then set h2534a; declare hash h(dataset:'h2534a',ordered:'d'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2534o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2534 rows=' rows;
else do; set h2534o; if not missing(actual) and abs(actual-(35))<=1e-9*max(1,abs(35)) then put 'ROUND6_PASS=H2534';
else put 'ERROR: ROUND6_FAIL=H2534 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2534:; quit;
