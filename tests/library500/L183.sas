/* L183: nmiss boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/sql_count_generate_missing_value_if_whole_col_is_missing.sas:52 */
data _null_;
actual=nmiss(.,.A,._,2);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L183';
else put 'ERROR: LIB500_FAIL=L183 actual=' actual;
run;
