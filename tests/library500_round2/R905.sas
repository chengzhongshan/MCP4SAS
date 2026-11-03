/* R905 input_double_at, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r905a; input value @@; datalines;
6 7 8
;
run;
proc sql; create table r905o as select sum(value) as actual from r905a; quit;

data _null_; if 0 then set r905o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R905 rows=' rows;
else do; set r905o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R905';
else put 'ERROR: ROUND2_FAIL=R905 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r905:; quit;
