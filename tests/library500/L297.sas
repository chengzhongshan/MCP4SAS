/* L297: countc boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaaaaaBBB','a');
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L297';
else put 'ERROR: LIB500_FAIL=L297 actual=' actual;
run;
