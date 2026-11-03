/* R911 input_colon_modifier, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:6 */

data r911a; input label :$20. value; datalines;
alpha 2
beta 3
;
run;
proc sql; create table r911o as select sum(value)+count(distinct label) as actual from r911a; quit;

data _null_; if 0 then set r911o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R911 rows=' rows;
else do; set r911o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R911';
else put 'ERROR: ROUND2_FAIL=R911 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r911:; quit;
