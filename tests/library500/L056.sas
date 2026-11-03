/* L056: round boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(-0.25,0.5);
if not missing(actual) and abs(actual-(-0.5)) <= 1e-11*max(1,abs(-0.5)) then put 'LIB500_PASS=L056';
else put 'ERROR: LIB500_FAIL=L056 actual=' actual;
run;
