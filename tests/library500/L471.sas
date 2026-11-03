/* L471: put boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(17,z4.);
if actual='0017' and lengthn(actual)=4 then put 'LIB500_PASS=L471';
else put 'ERROR: LIB500_FAIL=L471 actual=' actual;
run;
