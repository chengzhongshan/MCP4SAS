/* L325: translate boundary 4; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab4','XY','ab');
if actual='XY4' and lengthn(actual)=3 then put 'LIB500_PASS=L325';
else put 'ERROR: LIB500_FAIL=L325 actual=' actual;
run;
