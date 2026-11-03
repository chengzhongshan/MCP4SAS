/* L373: verify boundary 2; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaz','ab');
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L373';
else put 'ERROR: LIB500_FAIL=L373 actual=' actual;
run;
