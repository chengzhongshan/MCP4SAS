/* L147: mean boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,6,9);
if not missing(actual) and abs(actual-(7.5)) <= 1e-11*max(1,abs(7.5)) then put 'LIB500_PASS=L147';
else put 'ERROR: LIB500_FAIL=L147 actual=' actual;
run;
