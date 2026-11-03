/* L411: year boundary 0; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN1996'd);
if not missing(actual) and abs(actual-(1996)) <= 1e-11*max(1,abs(1996)) then put 'LIB500_PASS=L411';
else put 'ERROR: LIB500_FAIL=L411 actual=' actual;
run;
