/* L370: indexc boundary 9; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxxxxxxxxAB','BA');
if not missing(actual) and abs(actual-(10)) <= 1e-11*max(1,abs(10)) then put 'LIB500_PASS=L370';
else put 'ERROR: LIB500_FAIL=L370 actual=' actual;
run;
