/* L415: year boundary 4; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN2000'd);
if not missing(actual) and abs(actual-(2000)) <= 1e-11*max(1,abs(2000)) then put 'LIB500_PASS=L415';
else put 'ERROR: LIB500_FAIL=L415 actual=' actual;
run;
