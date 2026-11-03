/* R918 input_colon_modifier, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r918a; input label :$20. value; datalines;
alpha 9
beta 10
;
run;
proc sql; create table r918o as select sum(value)+count(distinct label) as actual from r918a; quit;

data _null_; if 0 then set r918o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R918 rows=' rows;
else do; set r918o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R918';
else put 'ERROR: ROUND2_FAIL=R918 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r918:; quit;
