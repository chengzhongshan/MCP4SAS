/* L486: repeat boundary 5; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',5);
if actual='xxxxxx' and lengthn(actual)=6 then put 'LIB500_PASS=L486';
else put 'ERROR: LIB500_FAIL=L486 actual=' actual;
run;
