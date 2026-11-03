/* L323: translate boundary 2; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab2','XY','ab');
if actual='XY2' and lengthn(actual)=3 then put 'LIB500_PASS=L323';
else put 'ERROR: LIB500_FAIL=L323 actual=' actual;
run;
