/* L118: min boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,7,-8);
if not missing(actual) and abs(actual-(-8)) <= 1e-11*max(1,abs(-8)) then put 'LIB500_PASS=L118';
else put 'ERROR: LIB500_FAIL=L118 actual=' actual;
run;
