/* H2571 hash_output_dataset, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2571a; do k=1 to 2; value=k*k; output; end; run;
data _null_; if 0 then set h2571a; declare hash h(dataset:'h2571a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2571b'); stop; run;
proc sql; create table h2571o as select sum(value) as actual from h2571b; quit;

data _null_; if 0 then set h2571o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2571 rows=' rows;
else do; set h2571o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2571';
else put 'ERROR: ROUND6_FAIL=H2571 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2571:; quit;
