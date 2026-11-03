/* H2568 hash_clear_all, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2568o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 9; rc=h.add(); end; before=h.num_items; rc=h.clear(); actual=before+(h.num_items=0); output; stop; run;

data _null_; if 0 then set h2568o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2568 rows=' rows;
else do; set h2568o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2568';
else put 'ERROR: ROUND6_FAIL=H2568 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2568:; quit;
