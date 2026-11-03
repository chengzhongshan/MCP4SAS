/* L472: put boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(18,z4.);
if actual='0018' and lengthn(actual)=4 then put 'LIB500_PASS=L472';
else put 'ERROR: LIB500_FAIL=L472 actual=' actual;
run;
