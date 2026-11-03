/* L051: round boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(-5.25,0.5);
if not missing(actual) and abs(actual-(-5.5)) <= 1e-11*max(1,abs(-5.5)) then put 'LIB500_PASS=L051';
else put 'ERROR: LIB500_FAIL=L051 actual=' actual;
run;
