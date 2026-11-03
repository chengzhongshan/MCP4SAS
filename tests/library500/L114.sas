/* L114: min boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,3,-4);
if not missing(actual) and abs(actual-(-4)) <= 1e-11*max(1,abs(-4)) then put 'LIB500_PASS=L114';
else put 'ERROR: LIB500_FAIL=L114 actual=' actual;
run;
