/* L082: exp boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(-4);
if not missing(actual) and abs(actual-(0.01831563888873418)) <= 1e-11*max(1,abs(0.01831563888873418)) then put 'LIB500_PASS=L082';
else put 'ERROR: LIB500_FAIL=L082 actual=' actual;
run;
