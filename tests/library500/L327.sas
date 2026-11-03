/* L327: translate boundary 6; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab6','XY','ab');
if actual='XY6' and lengthn(actual)=3 then put 'LIB500_PASS=L327';
else put 'ERROR: LIB500_FAIL=L327 actual=' actual;
run;
