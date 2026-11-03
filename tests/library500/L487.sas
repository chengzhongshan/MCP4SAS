/* L487: repeat boundary 6; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',6);
if actual='xxxxxxx' and lengthn(actual)=7 then put 'LIB500_PASS=L487';
else put 'ERROR: LIB500_FAIL=L487 actual=' actual;
run;
