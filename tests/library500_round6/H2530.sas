/* H2530 hash_iterator_ascending, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2530a; do k=11 to 1 by -1; output; end; run;
data h2530o; if 0 then set h2530a; declare hash h(dataset:'h2530a',ordered:'a'); h.definekey('k'); h.definedata('k'); h.definedone(); declare hiter it('h');
actual=0; serial=0; rc=it.first(); do while(rc=0); serial+1; actual=actual+k*serial; rc=it.next(); end; output; stop; run;

data _null_; if 0 then set h2530o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2530 rows=' rows;
else do; set h2530o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND6_PASS=H2530';
else put 'ERROR: ROUND6_FAIL=H2530 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2530:; quit;
