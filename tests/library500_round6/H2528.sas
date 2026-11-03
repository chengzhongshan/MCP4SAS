/* H2528 hash_iterator_ascending, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2528a; do k=9 to 1 by -1; output; end; run;
data h2528o; if 0 then set h2528a; declare hash h(dataset:'h2528a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2528o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2528 rows=' rows;
else do; set h2528o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND6_PASS=H2528';
else put 'ERROR: ROUND6_FAIL=H2528 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2528:; quit;
