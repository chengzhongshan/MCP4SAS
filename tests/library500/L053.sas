/* L053: round boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(-3.25,0.5);
if not missing(actual) and abs(actual-(-3.5)) <= 1e-11*max(1,abs(-3.5)) then put 'LIB500_PASS=L053';
else put 'ERROR: LIB500_FAIL=L053 actual=' actual;
run;
