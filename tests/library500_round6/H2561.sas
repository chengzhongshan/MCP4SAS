/* H2561 hash_clear_all, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2561o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 2; rc=h.add(); end; before=h.num_items; rc=h.clear(); actual=before+(h.num_items=0); output; stop; run;

data _null_; if 0 then set h2561o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2561 rows=' rows;
else do; set h2561o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2561';
else put 'ERROR: ROUND6_FAIL=H2561 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2561:; quit;
