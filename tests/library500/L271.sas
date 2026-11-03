/* L271: scan boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */
data _null_;
length actual $256;
actual=scan('w0|w1|w2|w3|w4|w5|w6|w7|w8|w9',1,'|');
if actual='w0' and lengthn(actual)=2 then put 'LIB500_PASS=L271';
else put 'ERROR: LIB500_FAIL=L271 actual=' actual;
run;
