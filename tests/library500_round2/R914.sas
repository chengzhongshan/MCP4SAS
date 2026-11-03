/* R914 input_colon_modifier, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r914a; input label :$20. value; datalines;
alpha 5
beta 6
;
run;
proc sql; create table r914o as select sum(value)+count(distinct label) as actual from r914a; quit;

data _null_; if 0 then set r914o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R914 rows=' rows;
else do; set r914o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND2_PASS=R914';
else put 'ERROR: ROUND2_FAIL=R914 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r914:; quit;
