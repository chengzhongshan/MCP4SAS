/* L104: log10 boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(1000);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L104';
else put 'ERROR: LIB500_FAIL=L104 actual=' actual;
run;
