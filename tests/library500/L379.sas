/* L379: verify boundary 8; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaaaaaaaz','ab');
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L379';
else put 'ERROR: LIB500_FAIL=L379 actual=' actual;
run;
