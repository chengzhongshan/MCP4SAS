/* R919 input_colon_modifier, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r919a; input label :$20. value; datalines;
alpha 10
beta 11
;
run;
proc sql; create table r919o as select sum(value)+count(distinct label) as actual from r919a; quit;

data _null_; if 0 then set r919o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R919 rows=' rows;
else do; set r919o; if not missing(actual) and abs(actual-(23))<=1e-10*max(1,abs(23)) then put 'ROUND2_PASS=R919';
else put 'ERROR: ROUND2_FAIL=R919 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r919:; quit;
