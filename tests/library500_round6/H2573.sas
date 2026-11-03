/* H2573 hash_output_dataset, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2573a; do k=1 to 4; value=k*k; output; end; run;
data _null_; if 0 then set h2573a; declare hash h(dataset:'h2573a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2573b'); stop; run;
proc sql; create table h2573o as select sum(value) as actual from h2573b; quit;

data _null_; if 0 then set h2573o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2573 rows=' rows;
else do; set h2573o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND6_PASS=H2573';
else put 'ERROR: ROUND6_FAIL=H2573 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2573:; quit;
