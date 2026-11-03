/* L062: sign boundary 1; source: SAS-Useful-Codes/Macros/SAS-macros-master/UnifyPow.sas:3579 */
data _null_;
actual=sign(-4);
if not missing(actual) and abs(actual-(-1)) <= 1e-11*max(1,abs(-1)) then put 'LIB500_PASS=L062';
else put 'ERROR: LIB500_FAIL=L062 actual=' actual;
run;
