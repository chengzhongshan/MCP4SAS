/* H2572 hash_output_dataset, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2572a; do k=1 to 3; value=k*k; output; end; run;
data _null_; if 0 then set h2572a; declare hash h(dataset:'h2572a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2572b'); stop; run;
proc sql; create table h2572o as select sum(value) as actual from h2572b; quit;

data _null_; if 0 then set h2572o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2572 rows=' rows;
else do; set h2572o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND6_PASS=H2572';
else put 'ERROR: ROUND6_FAIL=H2572 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2572:; quit;
