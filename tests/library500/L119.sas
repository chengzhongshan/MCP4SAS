/* L119: min boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get_minimum_or_max_value_for_any_of_specific_columns_with_having.sas:5 */
data _null_;
actual=min(.,8,-9);
if not missing(actual) and abs(actual-(-9)) <= 1e-11*max(1,abs(-9)) then put 'LIB500_PASS=L119';
else put 'ERROR: LIB500_FAIL=L119 actual=' actual;
run;
