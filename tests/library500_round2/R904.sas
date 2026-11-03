/* R904 input_double_at, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r904a; input value @@; datalines;
5 6 7
;
run;
proc sql; create table r904o as select sum(value) as actual from r904a; quit;

data _null_; if 0 then set r904o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R904 rows=' rows;
else do; set r904o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND2_PASS=R904';
else put 'ERROR: ROUND2_FAIL=R904 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r904:; quit;
