/* L120: min boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,9,-10);
if not missing(actual) and abs(actual-(-10)) <= 1e-11*max(1,abs(-10)) then put 'LIB500_PASS=L120';
else put 'ERROR: LIB500_FAIL=L120 actual=' actual;
run;
