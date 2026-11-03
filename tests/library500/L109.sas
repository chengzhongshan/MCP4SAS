/* L109: log10 boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(100000000);
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L109';
else put 'ERROR: LIB500_FAIL=L109 actual=' actual;
run;
