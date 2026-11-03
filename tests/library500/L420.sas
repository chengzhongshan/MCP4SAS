/* L420: year boundary 9; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN2005'd);
if not missing(actual) and abs(actual-(2005)) <= 1e-11*max(1,abs(2005)) then put 'LIB500_PASS=L420';
else put 'ERROR: LIB500_FAIL=L420 actual=' actual;
run;
