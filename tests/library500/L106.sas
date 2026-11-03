/* L106: log10 boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(100000);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L106';
else put 'ERROR: LIB500_FAIL=L106 actual=' actual;
run;
