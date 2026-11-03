/* H2525 hash_iterator_ascending, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2525a; do k=6 to 1 by -1; output; end; run;
data h2525o; if 0 then set h2525a; declare hash h(dataset:'h2525a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2525o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2525 rows=' rows;
else do; set h2525o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND6_PASS=H2525';
else put 'ERROR: ROUND6_FAIL=H2525 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2525:; quit;
