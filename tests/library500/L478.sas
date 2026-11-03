/* L478: put boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(24,z4.);
if actual='0024' and lengthn(actual)=4 then put 'LIB500_PASS=L478';
else put 'ERROR: LIB500_FAIL=L478 actual=' actual;
run;
