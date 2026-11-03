/* L101: log10 boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/calculate binomial P.sas:22 */
data _null_;
actual=log10(1);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L101';
else put 'ERROR: LIB500_FAIL=L101 actual=' actual;
run;
