/* L282: countw boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0 w1');
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L282';
else put 'ERROR: LIB500_FAIL=L282 actual=' actual;
run;
