/* R912 input_colon_modifier, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r912a; input label :$20. value; datalines;
alpha 3
beta 4
;
run;
proc sql; create table r912o as select sum(value)+count(distinct label) as actual from r912a; quit;

data _null_; if 0 then set r912o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R912 rows=' rows;
else do; set r912o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R912';
else put 'ERROR: ROUND2_FAIL=R912 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r912:; quit;
