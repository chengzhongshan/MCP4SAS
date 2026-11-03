/* R916 input_colon_modifier, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r916a; input label :$20. value; datalines;
alpha 7
beta 8
;
run;
proc sql; create table r916o as select sum(value)+count(distinct label) as actual from r916a; quit;

data _null_; if 0 then set r916o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R916 rows=' rows;
else do; set r916o; if not missing(actual) and abs(actual-(17))<=1e-10*max(1,abs(17)) then put 'ROUND2_PASS=R916';
else put 'ERROR: ROUND2_FAIL=R916 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r916:; quit;
