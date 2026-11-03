/* L300: countc boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaaaaaaaaBBB','a');
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L300';
else put 'ERROR: LIB500_FAIL=L300 actual=' actual;
run;
