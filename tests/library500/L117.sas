/* L117: min boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,6,-7);
if not missing(actual) and abs(actual-(-7)) <= 1e-11*max(1,abs(-7)) then put 'LIB500_PASS=L117';
else put 'ERROR: LIB500_FAIL=L117 actual=' actual;
run;
