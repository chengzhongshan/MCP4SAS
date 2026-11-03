/* L426: weekday boundary 5; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */
data _null_;
actual=weekday('01JAN2020'd+5);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L426';
else put 'ERROR: LIB500_FAIL=L426 actual=' actual;
run;
