/* L484: repeat boundary 3; source: SAS-Useful-Codes/Macros/Biplot.sas:45 */
data _null_;
length actual $256;
actual=repeat('x',3);
if actual='xxxx' and lengthn(actual)=4 then put 'LIB500_PASS=L484';
else put 'ERROR: LIB500_FAIL=L484 actual=' actual;
run;
