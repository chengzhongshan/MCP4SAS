/* L485: repeat boundary 4; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',4);
if actual='xxxxx' and lengthn(actual)=5 then put 'LIB500_PASS=L485';
else put 'ERROR: LIB500_FAIL=L485 actual=' actual;
run;
