/* L116: min boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,5,-6);
if not missing(actual) and abs(actual-(-6)) <= 1e-11*max(1,abs(-6)) then put 'LIB500_PASS=L116';
else put 'ERROR: LIB500_FAIL=L116 actual=' actual;
run;
