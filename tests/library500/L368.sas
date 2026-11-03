/* L368: indexc boundary 7; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxxxxxxAB','BA');
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L368';
else put 'ERROR: LIB500_FAIL=L368 actual=' actual;
run;
