/* L417: year boundary 6; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN2002'd);
if not missing(actual) and abs(actual-(2002)) <= 1e-11*max(1,abs(2002)) then put 'LIB500_PASS=L417';
else put 'ERROR: LIB500_FAIL=L417 actual=' actual;
run;
