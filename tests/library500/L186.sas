/* L186: nmiss boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/sql_count_generate_missing_value_if_whole_col_is_missing.sas:52 */
data _null_;
actual=nmiss(.,.A,._,5);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L186';
else put 'ERROR: LIB500_FAIL=L186 actual=' actual;
run;
