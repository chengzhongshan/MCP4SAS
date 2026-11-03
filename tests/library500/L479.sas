/* L479: put boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(25,z4.);
if actual='0025' and lengthn(actual)=4 then put 'LIB500_PASS=L479';
else put 'ERROR: LIB500_FAIL=L479 actual=' actual;
run;
