/* L414: year boundary 3; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN1999'd);
if not missing(actual) and abs(actual-(1999)) <= 1e-11*max(1,abs(1999)) then put 'LIB500_PASS=L414';
else put 'ERROR: LIB500_FAIL=L414 actual=' actual;
run;
