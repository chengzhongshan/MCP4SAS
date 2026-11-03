/* L413: year boundary 2; source: SAS-Useful-Codes/Macros/SAS-macros-master/getdata.sas:89 */
data _null_;
actual=year('01JAN1998'd);
if not missing(actual) and abs(actual-(1998)) <= 1e-11*max(1,abs(1998)) then put 'LIB500_PASS=L413';
else put 'ERROR: LIB500_FAIL=L413 actual=' actual;
run;
