/* H2574 hash_output_dataset, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/demo4hash_find_next_with_do_while_loop.sas:25 */

data h2574a; do k=1 to 5; value=k*k; output; end; run;
data _null_; if 0 then set h2574a; declare hash h(dataset:'h2574a'); h.definekey('k'); h.definedata('k','value'); h.definedone(); rc=h.output(dataset:'h2574b'); stop; run;
proc sql; create table h2574o as select sum(value) as actual from h2574b; quit;

data _null_; if 0 then set h2574o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2574 rows=' rows;
else do; set h2574o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND6_PASS=H2574';
else put 'ERROR: ROUND6_FAIL=H2574 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2574:; quit;
