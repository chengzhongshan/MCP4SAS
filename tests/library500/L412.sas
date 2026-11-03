/* L412: year boundary 1; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN1997'd);
if not missing(actual) and abs(actual-(1997)) <= 1e-11*max(1,abs(1997)) then put 'LIB500_PASS=L412';
else put 'ERROR: LIB500_FAIL=L412 actual=' actual;
run;
