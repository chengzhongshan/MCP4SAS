/* L145: mean boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,4,7);
if not missing(actual) and abs(actual-(5.5)) <= 1e-11*max(1,abs(5.5)) then put 'LIB500_PASS=L145';
else put 'ERROR: LIB500_FAIL=L145 actual=' actual;
run;
