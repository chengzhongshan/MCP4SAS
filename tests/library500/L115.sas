/* L115: min boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,4,-5);
if not missing(actual) and abs(actual-(-5)) <= 1e-11*max(1,abs(-5)) then put 'LIB500_PASS=L115';
else put 'ERROR: LIB500_FAIL=L115 actual=' actual;
run;
