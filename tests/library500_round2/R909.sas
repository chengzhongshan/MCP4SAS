/* R909 input_double_at, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r909a; input value @@; datalines;
10 11 12
;
run;
proc sql; create table r909o as select sum(value) as actual from r909a; quit;

data _null_; if 0 then set r909o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R909 rows=' rows;
else do; set r909o; if not missing(actual) and abs(actual-(33))<=1e-10*max(1,abs(33)) then put 'ROUND2_PASS=R909';
else put 'ERROR: ROUND2_FAIL=R909 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r909:; quit;
