/* L142: mean boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,1,4);
if not missing(actual) and abs(actual-(2.5)) <= 1e-11*max(1,abs(2.5)) then put 'LIB500_PASS=L142';
else put 'ERROR: LIB500_FAIL=L142 actual=' actual;
run;
