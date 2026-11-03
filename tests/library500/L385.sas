/* L385: count boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:14 */
data _null_;
actual=count('ababababZ','ab');
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L385';
else put 'ERROR: LIB500_FAIL=L385 actual=' actual;
run;
