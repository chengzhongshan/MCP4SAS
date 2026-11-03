/* R915 input_colon_modifier, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r915a; input label :$20. value; datalines;
alpha 6
beta 7
;
run;
proc sql; create table r915o as select sum(value)+count(distinct label) as actual from r915a; quit;

data _null_; if 0 then set r915o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R915 rows=' rows;
else do; set r915o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R915';
else put 'ERROR: ROUND2_FAIL=R915 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r915:; quit;
