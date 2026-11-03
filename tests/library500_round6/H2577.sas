/* H2577 hash_output_dataset, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2577a; do k=1 to 8; value=k*k; output; end; run;
data _null_; if 0 then set h2577a; declare hash h(dataset:'h2577a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2577b'); stop; run;
proc sql; create table h2577o as select sum(value) as actual from h2577b; quit;

data _null_; if 0 then set h2577o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2577 rows=' rows;
else do; set h2577o; if not missing(actual) and abs(actual-(204))<=1e-9*max(1,abs(204)) then put 'ROUND6_PASS=H2577';
else put 'ERROR: ROUND6_FAIL=H2577 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2577:; quit;
