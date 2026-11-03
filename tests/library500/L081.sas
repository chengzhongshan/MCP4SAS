/* L081: exp boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(-5);
if not missing(actual) and abs(actual-(0.006737946999085467)) <= 1e-11*max(1,abs(0.006737946999085467)) then put 'LIB500_PASS=L081';
else put 'ERROR: LIB500_FAIL=L081 actual=' actual;
run;
