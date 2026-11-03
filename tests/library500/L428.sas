/* L428: weekday boundary 7; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */
data _null_;
actual=weekday('01JAN2020'd+7);
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L428';
else put 'ERROR: LIB500_FAIL=L428 actual=' actual;
run;
