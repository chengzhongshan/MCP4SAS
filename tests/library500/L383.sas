/* L383: count boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('ababZ','ab');
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L383';
else put 'ERROR: LIB500_FAIL=L383 actual=' actual;
run;
