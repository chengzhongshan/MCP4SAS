/* H2522 hash_iterator_ascending, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2522a; do k=3 to 1 by -1; output; end; run;
data h2522o; if 0 then set h2522a; declare hash h(dataset:'h2522a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2522o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2522 rows=' rows;
else do; set h2522o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND6_PASS=H2522';
else put 'ERROR: ROUND6_FAIL=H2522 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2522:; quit;
