/* L045: mod boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/data stop array to create variables.sas:8 */
data _null_;
actual=mod(-1,3);
if not missing(actual) and abs(actual-(-1)) <= 1e-11*max(1,abs(-1)) then put 'LIB500_PASS=L045';
else put 'ERROR: LIB500_FAIL=L045 actual=' actual;
run;
