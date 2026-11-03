/* L087: exp boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(1);
if not missing(actual) and abs(actual-(2.718281828459045)) <= 1e-11*max(1,abs(2.718281828459045)) then put 'LIB500_PASS=L087';
else put 'ERROR: LIB500_FAIL=L087 actual=' actual;
run;
