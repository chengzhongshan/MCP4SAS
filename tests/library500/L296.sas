/* L296: countc boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('aaaaaBBB','a');
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L296';
else put 'ERROR: LIB500_FAIL=L296 actual=' actual;
run;
