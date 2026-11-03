/* L088: exp boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(2);
if not missing(actual) and abs(actual-(7.38905609893065)) <= 1e-11*max(1,abs(7.38905609893065)) then put 'LIB500_PASS=L088';
else put 'ERROR: LIB500_FAIL=L088 actual=' actual;
run;
