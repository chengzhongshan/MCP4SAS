/* L066: sign boundary 5; source: SAS-Useful-Codes/Macros/SAS-macros-master/UnifyPow.sas:3579 */
data _null_;
actual=sign(0);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L066';
else put 'ERROR: LIB500_FAIL=L066 actual=' actual;
run;
