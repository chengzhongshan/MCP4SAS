/* L488: repeat boundary 7; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',7);
if actual='xxxxxxxx' and lengthn(actual)=8 then put 'LIB500_PASS=L488';
else put 'ERROR: LIB500_FAIL=L488 actual=' actual;
run;
