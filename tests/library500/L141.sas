/* L141: mean boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/filter_data_step_records_with_mean_function_and_variable_shotcut.sas:3 */
data _null_;
actual=mean(.A,0,3);
if not missing(actual) and abs(actual-(1.5)) <= 1e-11*max(1,abs(1.5)) then put 'LIB500_PASS=L141';
else put 'ERROR: LIB500_FAIL=L141 actual=' actual;
run;
