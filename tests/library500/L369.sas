/* L369: indexc boundary 8; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:370 */
data _null_;
actual=indexc('xxxxxxxxAB','BA');
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L369';
else put 'ERROR: LIB500_FAIL=L369 actual=' actual;
run;
