/* L150: mean boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,9,12);
if not missing(actual) and abs(actual-(10.5)) <= 1e-11*max(1,abs(10.5)) then put 'LIB500_PASS=L150';
else put 'ERROR: LIB500_FAIL=L150 actual=' actual;
run;
