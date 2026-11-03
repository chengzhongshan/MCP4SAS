/* H2576 hash_output_dataset, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2576a; do k=1 to 7; value=k*k; output; end; run;
data _null_; if 0 then set h2576a; declare hash h(dataset:'h2576a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2576b'); stop; run;
proc sql; create table h2576o as select sum(value) as actual from h2576b; quit;

data _null_; if 0 then set h2576o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2576 rows=' rows;
else do; set h2576o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND6_PASS=H2576';
else put 'ERROR: ROUND6_FAIL=H2576 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2576:; quit;
