/* H2580 hash_output_dataset, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2580a; do k=1 to 11; value=k*k; output; end; run;
data _null_; if 0 then set h2580a; declare hash h(dataset:'h2580a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2580b'); stop; run;
proc sql; create table h2580o as select sum(value) as actual from h2580b; quit;

data _null_; if 0 then set h2580o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2580 rows=' rows;
else do; set h2580o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND6_PASS=H2580';
else put 'ERROR: ROUND6_FAIL=H2580 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2580:; quit;
