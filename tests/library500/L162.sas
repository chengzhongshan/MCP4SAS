/* L162: range boundary 1; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,1,3,-2);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L162';
else put 'ERROR: LIB500_FAIL=L162 actual=' actual;
run;
