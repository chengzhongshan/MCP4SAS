/* L477: put boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(23,z4.);
if actual='0023' and lengthn(actual)=4 then put 'LIB500_PASS=L477';
else put 'ERROR: LIB500_FAIL=L477 actual=' actual;
run;
