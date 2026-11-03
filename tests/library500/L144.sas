/* L144: mean boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,3,6);
if not missing(actual) and abs(actual-(4.5)) <= 1e-11*max(1,abs(4.5)) then put 'LIB500_PASS=L144';
else put 'ERROR: LIB500_FAIL=L144 actual=' actual;
run;
