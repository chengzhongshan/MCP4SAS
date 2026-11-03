/* H2516 hash_multidata_next, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2516a; do k=1 to 7; value=k; output; value=k+10; output; end; run;
data h2516o; if 0 then set h2516a; declare hash h(dataset:'h2516a',multidata:'y'); h.definekey('k'); h.definedata('value'); h.definedone();
actual=0; do k=1 to 7; rc=h.find(); do while(rc=0); actual=actual+value; rc=h.find_next(); end; end; output; stop; run;

data _null_; if 0 then set h2516o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2516 rows=' rows;
else do; set h2516o; if not missing(actual) and abs(actual-(126))<=1e-9*max(1,abs(126)) then put 'ROUND6_PASS=H2516';
else put 'ERROR: ROUND6_FAIL=H2516 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2516:; quit;
