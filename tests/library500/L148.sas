/* L148: mean boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,7,10);
if not missing(actual) and abs(actual-(8.5)) <= 1e-11*max(1,abs(8.5)) then put 'LIB500_PASS=L148';
else put 'ERROR: LIB500_FAIL=L148 actual=' actual;
run;
