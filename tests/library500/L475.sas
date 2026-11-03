/* L475: put boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(21,z4.);
if actual='0021' and lengthn(actual)=4 then put 'LIB500_PASS=L475';
else put 'ERROR: LIB500_FAIL=L475 actual=' actual;
run;
