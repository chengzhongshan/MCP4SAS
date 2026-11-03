/* L295: countc boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaaaBBB','a');
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L295';
else put 'ERROR: LIB500_FAIL=L295 actual=' actual;
run;
