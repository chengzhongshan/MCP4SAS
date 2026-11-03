/* H2570 hash_clear_all, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2570o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 11; rc=h.add(); end; before=h.num_items; rc=h.clear(); actual=before+(h.num_items=0); output; stop; run;

data _null_; if 0 then set h2570o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2570 rows=' rows;
else do; set h2570o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2570';
else put 'ERROR: ROUND6_FAIL=H2570 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2570:; quit;
