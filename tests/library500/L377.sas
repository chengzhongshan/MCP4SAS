/* L377: verify boundary 6; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaaaaaz','ab');
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L377';
else put 'ERROR: LIB500_FAIL=L377 actual=' actual;
run;
