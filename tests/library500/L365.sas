/* L365: indexc boundary 4; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxxxAB','BA');
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L365';
else put 'ERROR: LIB500_FAIL=L365 actual=' actual;
run;
