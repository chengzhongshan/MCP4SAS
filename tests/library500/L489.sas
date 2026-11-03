/* L489: repeat boundary 8; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',8);
if actual='xxxxxxxxx' and lengthn(actual)=9 then put 'LIB500_PASS=L489';
else put 'ERROR: LIB500_FAIL=L489 actual=' actual;
run;
