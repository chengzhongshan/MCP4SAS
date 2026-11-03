/* H2524 hash_iterator_ascending, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2524a; do k=5 to 1 by -1; output; end; run;
data h2524o; if 0 then set h2524a; declare hash h(dataset:'h2524a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2524o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2524 rows=' rows;
else do; set h2524o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND6_PASS=H2524';
else put 'ERROR: ROUND6_FAIL=H2524 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2524:; quit;
