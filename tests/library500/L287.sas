/* L287: countw boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0 w1 w2 w3 w4 w5 w6');
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L287';
else put 'ERROR: LIB500_FAIL=L287 actual=' actual;
run;
