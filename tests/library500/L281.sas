/* L281: countw boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0');
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L281';
else put 'ERROR: LIB500_FAIL=L281 actual=' actual;
run;
