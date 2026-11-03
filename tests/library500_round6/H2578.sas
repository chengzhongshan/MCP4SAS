/* H2578 hash_output_dataset, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2578a; do k=1 to 9; value=k*k; output; end; run;
data _null_; if 0 then set h2578a; declare hash h(dataset:'h2578a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2578b'); stop; run;
proc sql; create table h2578o as select sum(value) as actual from h2578b; quit;

data _null_; if 0 then set h2578o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2578 rows=' rows;
else do; set h2578o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND6_PASS=H2578';
else put 'ERROR: ROUND6_FAIL=H2578 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2578:; quit;
