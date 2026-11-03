/* L083: exp boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(-3);
if not missing(actual) and abs(actual-(0.04978706836786394)) <= 1e-11*max(1,abs(0.04978706836786394)) then put 'LIB500_PASS=L083';
else put 'ERROR: LIB500_FAIL=L083 actual=' actual;
run;
