/* H2560 hash_remove_entries, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2560o; length k 8; declare hash h(); h.definekey('k'); h.definedata('k'); h.definedone();
do k=1 to 11; rc=h.add(); end; do k=2 to 11 by 2; rc=h.remove(); end;
k=2; rc=h.find(); actual=h.num_items+11*(rc ne 0); output; stop; run;

data _null_; if 0 then set h2560o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2560 rows=' rows;
else do; set h2560o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND6_PASS=H2560';
else put 'ERROR: ROUND6_FAIL=H2560 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2560:; quit;
