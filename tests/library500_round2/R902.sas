/* R902 input_double_at, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r902a; input value @@; datalines;
3 4 5
;
run;
proc sql; create table r902o as select sum(value) as actual from r902a; quit;

data _null_; if 0 then set r902o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R902 rows=' rows;
else do; set r902o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND2_PASS=R902';
else put 'ERROR: ROUND2_FAIL=R902 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r902:; quit;
