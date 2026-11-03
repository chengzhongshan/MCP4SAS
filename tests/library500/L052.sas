/* L052: round boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(-4.25,0.5);
if not missing(actual) and abs(actual-(-4.5)) <= 1e-11*max(1,abs(-4.5)) then put 'LIB500_PASS=L052';
else put 'ERROR: LIB500_FAIL=L052 actual=' actual;
run;
