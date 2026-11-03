/* L371: verify boundary 0; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('z','ab');
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L371';
else put 'ERROR: LIB500_FAIL=L371 actual=' actual;
run;
