/* L321: translate boundary 0; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab0','XY','ab');
if actual='XY0' and lengthn(actual)=3 then put 'LIB500_PASS=L321';
else put 'ERROR: LIB500_FAIL=L321 actual=' actual;
run;
