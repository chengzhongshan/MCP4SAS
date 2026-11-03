/* L361: indexc boundary 0; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('AB','BA');
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L361';
else put 'ERROR: LIB500_FAIL=L361 actual=' actual;
run;
