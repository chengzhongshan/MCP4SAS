/* L322: translate boundary 1; source: SAS-Useful-Codes/Macros/CompareGenoA1A2.sas:8 */
data _null_;
length actual $256;
actual=translate('ab1','XY','ab');
if actual='XY1' and lengthn(actual)=3 then put 'LIB500_PASS=L322';
else put 'ERROR: LIB500_FAIL=L322 actual=' actual;
run;
