/* L382: count boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('abZ','ab');
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L382';
else put 'ERROR: LIB500_FAIL=L382 actual=' actual;
run;
