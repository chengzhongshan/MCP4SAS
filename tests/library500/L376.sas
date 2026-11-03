/* L376: verify boundary 5; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaaaaz','ab');
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L376';
else put 'ERROR: LIB500_FAIL=L376 actual=' actual;
run;
