/* R910 input_double_at, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r910a; input value @@; datalines;
11 12 13
;
run;
proc sql; create table r910o as select sum(value) as actual from r910a; quit;

data _null_; if 0 then set r910o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R910 rows=' rows;
else do; set r910o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R910';
else put 'ERROR: ROUND2_FAIL=R910 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r910:; quit;
