/* L055: round boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(-1.25,0.5);
if not missing(actual) and abs(actual-(-1.5)) <= 1e-11*max(1,abs(-1.5)) then put 'LIB500_PASS=L055';
else put 'ERROR: LIB500_FAIL=L055 actual=' actual;
run;
