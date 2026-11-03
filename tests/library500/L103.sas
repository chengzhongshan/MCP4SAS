/* L103: log10 boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(100);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L103';
else put 'ERROR: LIB500_FAIL=L103 actual=' actual;
run;
