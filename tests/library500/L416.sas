/* L416: year boundary 5; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN2001'd);
if not missing(actual) and abs(actual-(2001)) <= 1e-11*max(1,abs(2001)) then put 'LIB500_PASS=L416';
else put 'ERROR: LIB500_FAIL=L416 actual=' actual;
run;
