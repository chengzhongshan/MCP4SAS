/* H2563 hash_clear_all, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2563o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 4; rc=h.add(); end; before=h.num_items; rc=h.clear(); actual=before+(h.num_items=0); output; stop; run;

data _null_; if 0 then set h2563o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2563 rows=' rows;
else do; set h2563o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2563';
else put 'ERROR: ROUND6_FAIL=H2563 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2563:; quit;
