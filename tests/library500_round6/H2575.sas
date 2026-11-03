/* H2575 hash_output_dataset, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2575a; do k=1 to 6; value=k*k; output; end; run;
data _null_; if 0 then set h2575a; declare hash h(dataset:'h2575a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2575b'); stop; run;
proc sql; create table h2575o as select sum(value) as actual from h2575b; quit;

data _null_; if 0 then set h2575o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2575 rows=' rows;
else do; set h2575o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND6_PASS=H2575';
else put 'ERROR: ROUND6_FAIL=H2575 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2575:; quit;
