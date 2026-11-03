/* H2569 hash_clear_all, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2569o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 10; rc=h.add(); end; before=h.num_items; rc=h.clear(); actual=before+(h.num_items=0); output; stop; run;

data _null_; if 0 then set h2569o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2569 rows=' rows;
else do; set h2569o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2569';
else put 'ERROR: ROUND6_FAIL=H2569 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2569:; quit;
