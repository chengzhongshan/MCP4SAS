/* L291: countc boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:6 */
data _null_;
actual=countc('BBB','a');
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L291';
else put 'ERROR: LIB500_FAIL=L291 actual=' actual;
run;
