/* L113: min boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,2,-3);
if not missing(actual) and abs(actual-(-3)) <= 1e-11*max(1,abs(-3)) then put 'LIB500_PASS=L113';
else put 'ERROR: LIB500_FAIL=L113 actual=' actual;
run;
