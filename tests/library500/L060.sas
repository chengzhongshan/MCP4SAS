/* L060: round boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use GROUP for print characters in Proc Report.sas:35 */
data _null_;
actual=round(3.75,0.5);
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L060';
else put 'ERROR: LIB500_FAIL=L060 actual=' actual;
run;
