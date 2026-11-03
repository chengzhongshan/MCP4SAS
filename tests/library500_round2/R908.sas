/* R908 input_double_at, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r908a; input value @@; datalines;
9 10 11
;
run;
proc sql; create table r908o as select sum(value) as actual from r908a; quit;

data _null_; if 0 then set r908o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R908 rows=' rows;
else do; set r908o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND2_PASS=R908';
else put 'ERROR: ROUND2_FAIL=R908 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r908:; quit;
