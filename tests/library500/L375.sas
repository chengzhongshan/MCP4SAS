/* L375: verify boundary 4; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaaaz','ab');
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L375';
else put 'ERROR: LIB500_FAIL=L375 actual=' actual;
run;
