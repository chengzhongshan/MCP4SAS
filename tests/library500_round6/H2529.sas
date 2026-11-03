/* H2529 hash_iterator_ascending, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2529a; do k=10 to 1 by -1; output; end; run;
data h2529o; if 0 then set h2529a; declare hash h(dataset:'h2529a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2529o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2529 rows=' rows;
else do; set h2529o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND6_PASS=H2529';
else put 'ERROR: ROUND6_FAIL=H2529 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2529:; quit;
