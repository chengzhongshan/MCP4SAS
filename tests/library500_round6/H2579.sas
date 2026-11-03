/* H2579 hash_output_dataset, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2579a; do k=1 to 10; value=k*k; output; end; run;
data _null_; if 0 then set h2579a; declare hash h(dataset:'h2579a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2579b'); stop; run;
proc sql; create table h2579o as select sum(value) as actual from h2579b; quit;

data _null_; if 0 then set h2579o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2579 rows=' rows;
else do; set h2579o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND6_PASS=H2579';
else put 'ERROR: ROUND6_FAIL=H2579 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2579:; quit;
