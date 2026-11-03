/* L107: log10 boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(1000000);
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L107';
else put 'ERROR: LIB500_FAIL=L107 actual=' actual;
run;
