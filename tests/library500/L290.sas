/* L290: countw boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0 w1 w2 w3 w4 w5 w6 w7 w8 w9');
if not missing(actual) and abs(actual-(10)) <= 1e-11*max(1,abs(10)) then put 'LIB500_PASS=L290';
else put 'ERROR: LIB500_FAIL=L290 actual=' actual;
run;
