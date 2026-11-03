/* L090: exp boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(4);
if not missing(actual) and abs(actual-(54.59815003314424)) <= 1e-11*max(1,abs(54.59815003314424)) then put 'LIB500_PASS=L090';
else put 'ERROR: LIB500_FAIL=L090 actual=' actual;
run;
