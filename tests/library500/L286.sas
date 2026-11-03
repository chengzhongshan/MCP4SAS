/* L286: countw boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */
data _null_;
actual=countw('w0 w1 w2 w3 w4 w5');
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L286';
else put 'ERROR: LIB500_FAIL=L286 actual=' actual;
run;
