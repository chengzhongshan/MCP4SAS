/* L146: mean boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,5,8);
if not missing(actual) and abs(actual-(6.5)) <= 1e-11*max(1,abs(6.5)) then put 'LIB500_PASS=L146';
else put 'ERROR: LIB500_FAIL=L146 actual=' actual;
run;
