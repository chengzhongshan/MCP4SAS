/* L381: count boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('Z','ab');
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L381';
else put 'ERROR: LIB500_FAIL=L381 actual=' actual;
run;
