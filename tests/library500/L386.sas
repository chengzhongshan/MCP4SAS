/* L386: count boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('abababababZ','ab');
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L386';
else put 'ERROR: LIB500_FAIL=L386 actual=' actual;
run;
