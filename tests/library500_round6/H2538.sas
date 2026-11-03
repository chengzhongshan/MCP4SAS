/* H2538 hash_iterator_descending, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2538a; do k=1 to 9; output; end; run;
data h2538o; if 0 then set h2538a; declare hash h(dataset:'h2538a',ordered:'d'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2538o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2538 rows=' rows;
else do; set h2538o; if not missing(actual) and abs(actual-(165))<=1e-9*max(1,abs(165)) then put 'ROUND6_PASS=H2538';
else put 'ERROR: ROUND6_FAIL=H2538 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2538:; quit;
