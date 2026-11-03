/* H2523 hash_iterator_ascending, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2523a; do k=4 to 1 by -1; output; end; run;
data h2523o; if 0 then set h2523a; declare hash h(dataset:'h2523a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2523o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2523 rows=' rows;
else do; set h2523o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND6_PASS=H2523';
else put 'ERROR: ROUND6_FAIL=H2523 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2523:; quit;
