/* L483: repeat boundary 2; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',2);
if actual='xxx' and lengthn(actual)=3 then put 'LIB500_PASS=L483';
else put 'ERROR: LIB500_FAIL=L483 actual=' actual;
run;
