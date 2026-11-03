/* L374: verify boundary 3; source: SAS-Useful-Codes/Macros/MacroNotUsed/xls input macro.sas:251 */
data _null_;
actual=verify('aaaz','ab');
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L374';
else put 'ERROR: LIB500_FAIL=L374 actual=' actual;
run;
