/* L422: weekday boundary 1; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */
data _null_;
actual=weekday('01JAN2020'd+1);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L422';
else put 'ERROR: LIB500_FAIL=L422 actual=' actual;
run;
