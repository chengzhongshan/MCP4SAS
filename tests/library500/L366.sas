/* L366: indexc boundary 5; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxxxxAB','BA');
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L366';
else put 'ERROR: LIB500_FAIL=L366 actual=' actual;
run;
