/* L419: year boundary 8; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN2004'd);
if not missing(actual) and abs(actual-(2004)) <= 1e-11*max(1,abs(2004)) then put 'LIB500_PASS=L419';
else put 'ERROR: LIB500_FAIL=L419 actual=' actual;
run;
