/* L364: indexc boundary 3; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxxAB','BA');
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L364';
else put 'ERROR: LIB500_FAIL=L364 actual=' actual;
run;
