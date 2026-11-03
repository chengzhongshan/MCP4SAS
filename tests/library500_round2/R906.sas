/* R906 input_double_at, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r906a; input value @@; datalines;
7 8 9
;
run;
proc sql; create table r906o as select sum(value) as actual from r906a; quit;

data _null_; if 0 then set r906o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R906 rows=' rows;
else do; set r906o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND2_PASS=R906';
else put 'ERROR: ROUND2_FAIL=R906 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r906:; quit;
