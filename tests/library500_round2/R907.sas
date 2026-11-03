/* R907 input_double_at, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r907a; input value @@; datalines;
8 9 10
;
run;
proc sql; create table r907o as select sum(value) as actual from r907a; quit;

data _null_; if 0 then set r907o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R907 rows=' rows;
else do; set r907o; if not missing(actual) and abs(actual-(27))<=1e-10*max(1,abs(27)) then put 'ROUND2_PASS=R907';
else put 'ERROR: ROUND2_FAIL=R907 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r907:; quit;
