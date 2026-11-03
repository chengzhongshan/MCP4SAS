/* L329: translate boundary 8; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab8','XY','ab');
if actual='XY8' and lengthn(actual)=3 then put 'LIB500_PASS=L329';
else put 'ERROR: LIB500_FAIL=L329 actual=' actual;
run;
