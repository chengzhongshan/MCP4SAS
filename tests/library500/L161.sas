/* L161: range boundary 0; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,0,2,-1);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L161';
else put 'ERROR: LIB500_FAIL=L161 actual=' actual;
run;
