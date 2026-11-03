/* L430: weekday boundary 9; source: SAS-Useful-Codes/Macros/dmtoolsSAS-master/TimeSeries/com_mac_createdummies.sas:116 */
data _null_;
actual=weekday('01JAN2020'd+9);
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L430';
else put 'ERROR: LIB500_FAIL=L430 actual=' actual;
run;
