/* L476: put boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(22,z4.);
if actual='0022' and lengthn(actual)=4 then put 'LIB500_PASS=L476';
else put 'ERROR: LIB500_FAIL=L476 actual=' actual;
run;
