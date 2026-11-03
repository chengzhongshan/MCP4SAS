/* L049: mod boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/data stop array to create variables.sas:8 */
data _null_;
actual=mod(3,3);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L049';
else put 'ERROR: LIB500_FAIL=L049 actual=' actual;
run;
