/* L330: translate boundary 9; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab9','XY','ab');
if actual='XY9' and lengthn(actual)=3 then put 'LIB500_PASS=L330';
else put 'ERROR: LIB500_FAIL=L330 actual=' actual;
run;
