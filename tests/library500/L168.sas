/* L168: range boundary 7; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,7,9,-8);
if not missing(actual) and abs(actual-(17)) <= 1e-11*max(1,abs(17)) then put 'LIB500_PASS=L168';
else put 'ERROR: LIB500_FAIL=L168 actual=' actual;
run;
