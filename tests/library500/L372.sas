/* L372: verify boundary 1; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('az','ab');
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L372';
else put 'ERROR: LIB500_FAIL=L372 actual=' actual;
run;
