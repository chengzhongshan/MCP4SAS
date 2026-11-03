/* L480: put boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(26,z4.);
if actual='0026' and lengthn(actual)=4 then put 'LIB500_PASS=L480';
else put 'ERROR: LIB500_FAIL=L480 actual=' actual;
run;
