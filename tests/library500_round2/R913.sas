/* R913 input_colon_modifier, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r913a; input label :$20. value; datalines;
alpha 4
beta 5
;
run;
proc sql; create table r913o as select sum(value)+count(distinct label) as actual from r913a; quit;

data _null_; if 0 then set r913o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R913 rows=' rows;
else do; set r913o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R913';
else put 'ERROR: ROUND2_FAIL=R913 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r913:; quit;
