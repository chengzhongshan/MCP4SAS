/* L378: verify boundary 7; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaaaaaaz','ab');
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L378';
else put 'ERROR: LIB500_FAIL=L378 actual=' actual;
run;
