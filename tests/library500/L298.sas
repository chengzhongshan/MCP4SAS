/* L298: countc boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaaaaaaBBB','a');
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L298';
else put 'ERROR: LIB500_FAIL=L298 actual=' actual;
run;
