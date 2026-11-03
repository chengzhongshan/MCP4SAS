/* L481: repeat boundary 0; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',0);
if actual='x' and lengthn(actual)=1 then put 'LIB500_PASS=L481';
else put 'ERROR: LIB500_FAIL=L481 actual=' actual;
run;
