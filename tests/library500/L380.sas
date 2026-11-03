/* L380: verify boundary 9; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaaaaaaaaz','ab');
if not missing(actual) and abs(actual-(10)) <= 1e-11*max(1,abs(10)) then put 'LIB500_PASS=L380';
else put 'ERROR: LIB500_FAIL=L380 actual=' actual;
run;
