/* L102: log10 boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(10);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L102';
else put 'ERROR: LIB500_FAIL=L102 actual=' actual;
run;
