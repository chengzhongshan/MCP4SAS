/* L328: translate boundary 7; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab7','XY','ab');
if actual='XY7' and lengthn(actual)=3 then put 'LIB500_PASS=L328';
else put 'ERROR: LIB500_FAIL=L328 actual=' actual;
run;
