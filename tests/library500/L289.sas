/* L289: countw boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0 w1 w2 w3 w4 w5 w6 w7 w8');
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L289';
else put 'ERROR: LIB500_FAIL=L289 actual=' actual;
run;
