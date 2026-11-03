/* L367: indexc boundary 6; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxxxxxAB','BA');
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L367';
else put 'ERROR: LIB500_FAIL=L367 actual=' actual;
run;
