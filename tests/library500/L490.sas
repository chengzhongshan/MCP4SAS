/* L490: repeat boundary 9; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',9);
if actual='xxxxxxxxxx' and lengthn(actual)=10 then put 'LIB500_PASS=L490';
else put 'ERROR: LIB500_FAIL=L490 actual=' actual;
run;
