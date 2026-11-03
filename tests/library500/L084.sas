/* L084: exp boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(-2);
if not missing(actual) and abs(actual-(0.1353352832366127)) <= 1e-11*max(1,abs(0.1353352832366127)) then put 'LIB500_PASS=L084';
else put 'ERROR: LIB500_FAIL=L084 actual=' actual;
run;
