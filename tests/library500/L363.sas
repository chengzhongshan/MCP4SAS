/* L363: indexc boundary 2; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxAB','BA');
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L363';
else put 'ERROR: LIB500_FAIL=L363 actual=' actual;
run;
