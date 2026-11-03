/* L057: round boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(0.75,0.5);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L057';
else put 'ERROR: LIB500_FAIL=L057 actual=' actual;
run;
