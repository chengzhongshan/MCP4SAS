/* L143: mean boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,2,5);
if not missing(actual) and abs(actual-(3.5)) <= 1e-11*max(1,abs(3.5)) then put 'LIB500_PASS=L143';
else put 'ERROR: LIB500_FAIL=L143 actual=' actual;
run;
