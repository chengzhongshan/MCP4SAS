/* L418: year boundary 7; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN2003'd);
if not missing(actual) and abs(actual-(2003)) <= 1e-11*max(1,abs(2003)) then put 'LIB500_PASS=L418';
else put 'ERROR: LIB500_FAIL=L418 actual=' actual;
run;
