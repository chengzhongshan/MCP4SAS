/* L362: indexc boundary 1; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xAB','BA');
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L362';
else put 'ERROR: LIB500_FAIL=L362 actual=' actual;
run;
