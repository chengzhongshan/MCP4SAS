/* L085: exp boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(-1);
if not missing(actual) and abs(actual-(0.3678794411714423)) <= 1e-11*max(1,abs(0.3678794411714423)) then put 'LIB500_PASS=L085';
else put 'ERROR: LIB500_FAIL=L085 actual=' actual;
run;
