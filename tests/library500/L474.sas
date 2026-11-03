/* L474: put boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(20,z4.);
if actual='0020' and lengthn(actual)=4 then put 'LIB500_PASS=L474';
else put 'ERROR: LIB500_FAIL=L474 actual=' actual;
run;
