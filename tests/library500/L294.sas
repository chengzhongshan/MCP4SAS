/* L294: countc boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaaBBB','a');
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L294';
else put 'ERROR: LIB500_FAIL=L294 actual=' actual;
run;
