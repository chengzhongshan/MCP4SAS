/* L058: round boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(1.75,0.5);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L058';
else put 'ERROR: LIB500_FAIL=L058 actual=' actual;
run;
