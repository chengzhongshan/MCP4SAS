/* L054: round boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(-2.25,0.5);
if not missing(actual) and abs(actual-(-2.5)) <= 1e-11*max(1,abs(-2.5)) then put 'LIB500_PASS=L054';
else put 'ERROR: LIB500_FAIL=L054 actual=' actual;
run;
