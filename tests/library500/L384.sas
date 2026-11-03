/* L384: count boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('abababZ','ab');
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L384';
else put 'ERROR: LIB500_FAIL=L384 actual=' actual;
run;
