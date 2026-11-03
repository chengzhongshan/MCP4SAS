/* L111: min boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,0,-1);
if not missing(actual) and abs(actual-(-1)) <= 1e-11*max(1,abs(-1)) then put 'LIB500_PASS=L111';
else put 'ERROR: LIB500_FAIL=L111 actual=' actual;
run;
