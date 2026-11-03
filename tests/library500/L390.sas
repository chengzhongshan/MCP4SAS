/* L390: count boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('abababababababababZ','ab');
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L390';
else put 'ERROR: LIB500_FAIL=L390 actual=' actual;
run;
