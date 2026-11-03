/* R920 input_colon_modifier, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r920a; input label :$20. value; datalines;
alpha 11
beta 12
;
run;
proc sql; create table r920o as select sum(value)+count(distinct label) as actual from r920a; quit;

data _null_; if 0 then set r920o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R920 rows=' rows;
else do; set r920o; if not missing(actual) and abs(actual-(25))<=1e-10*max(1,abs(25)) then put 'ROUND2_PASS=R920';
else put 'ERROR: ROUND2_FAIL=R920 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r920:; quit;
