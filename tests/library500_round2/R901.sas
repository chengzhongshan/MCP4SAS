/* R901 input_double_at, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Tell_sas_to_read_var_in_variable_length.sas:13 */

data r901a; input value @@; datalines;
2 3 4
;
run;
proc sql; create table r901o as select sum(value) as actual from r901a; quit;

data _null_; if 0 then set r901o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R901 rows=' rows;
else do; set r901o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R901';
else put 'ERROR: ROUND2_FAIL=R901 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r901:; quit;
