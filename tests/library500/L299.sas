/* L299: countc boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaaaaaaaBBB','a');
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L299';
else put 'ERROR: LIB500_FAIL=L299 actual=' actual;
run;
