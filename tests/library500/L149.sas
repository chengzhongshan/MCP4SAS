/* L149: mean boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,8,11);
if not missing(actual) and abs(actual-(9.5)) <= 1e-11*max(1,abs(9.5)) then put 'LIB500_PASS=L149';
else put 'ERROR: LIB500_FAIL=L149 actual=' actual;
run;
