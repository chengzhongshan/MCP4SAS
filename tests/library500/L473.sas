/* L473: put boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to use strip in prxchange.sas:13 */
data _null_;
length actual $256;
actual=put(19,z4.);
if actual='0019' and lengthn(actual)=4 then put 'LIB500_PASS=L473';
else put 'ERROR: LIB500_FAIL=L473 actual=' actual;
run;
