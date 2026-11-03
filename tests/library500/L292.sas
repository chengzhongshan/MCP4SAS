/* L292: countc boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aBBB','a');
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L292';
else put 'ERROR: LIB500_FAIL=L292 actual=' actual;
run;
