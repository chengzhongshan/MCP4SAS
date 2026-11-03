/* L389: count boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('ababababababababZ','ab');
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L389';
else put 'ERROR: LIB500_FAIL=L389 actual=' actual;
run;
