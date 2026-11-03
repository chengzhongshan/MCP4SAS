/* H2535 hash_iterator_descending, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2535a; do k=1 to 6; output; end; run;
data h2535o; if 0 then set h2535a; declare hash h(dataset:'h2535a',ordered:'d'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2535o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2535 rows=' rows;
else do; set h2535o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND6_PASS=H2535';
else put 'ERROR: ROUND6_FAIL=H2535 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2535:; quit;
