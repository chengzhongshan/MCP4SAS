/* L048: mod boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/data stop array to create variables.sas:8 */
data _null_;
actual=mod(2,3);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L048';
else put 'ERROR: LIB500_FAIL=L048 actual=' actual;
run;
