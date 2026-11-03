/* L293: countc boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaBBB','a');
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L293';
else put 'ERROR: LIB500_FAIL=L293 actual=' actual;
run;
