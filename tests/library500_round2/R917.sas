/* R917 input_colon_modifier, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r917a; input label :$20. value; datalines;
alpha 8
beta 9
;
run;
proc sql; create table r917o as select sum(value)+count(distinct label) as actual from r917a; quit;

data _null_; if 0 then set r917o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R917 rows=' rows;
else do; set r917o; if not missing(actual) and abs(actual-(19))<=1e-10*max(1,abs(19)) then put 'ROUND2_PASS=R917';
else put 'ERROR: ROUND2_FAIL=R917 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r917:; quit;
