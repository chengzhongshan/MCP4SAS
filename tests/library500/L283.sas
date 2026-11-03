/* L283: countw boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0 w1 w2');
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L283';
else put 'ERROR: LIB500_FAIL=L283 actual=' actual;
run;
