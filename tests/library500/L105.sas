/* L105: log10 boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(10000);
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L105';
else put 'ERROR: LIB500_FAIL=L105 actual=' actual;
run;
