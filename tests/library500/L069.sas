/* L069: sign boundary 8; source: SAS-Useful-Codes/Macros/SAS-macros-master/UnifyPow.sas:3579 */
data _null_;
actual=sign(3);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L069';
else put 'ERROR: LIB500_FAIL=L069 actual=' actual;
run;
