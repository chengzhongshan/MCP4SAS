/* L288: countw boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0 w1 w2 w3 w4 w5 w6 w7');
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L288';
else put 'ERROR: LIB500_FAIL=L288 actual=' actual;
run;
