/* L110: log10 boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(1000000000);
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L110';
else put 'ERROR: LIB500_FAIL=L110 actual=' actual;
run;
