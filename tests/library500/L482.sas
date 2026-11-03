/* L482: repeat boundary 1; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',1);
if actual='xx' and lengthn(actual)=2 then put 'LIB500_PASS=L482';
else put 'ERROR: LIB500_FAIL=L482 actual=' actual;
run;
