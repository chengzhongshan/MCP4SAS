/* L326: translate boundary 5; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab5','XY','ab');
if actual='XY5' and lengthn(actual)=3 then put 'LIB500_PASS=L326';
else put 'ERROR: LIB500_FAIL=L326 actual=' actual;
run;
