/* L167: range boundary 6; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,6,8,-7);
if not missing(actual) and abs(actual-(15)) <= 1e-11*max(1,abs(15)) then put 'LIB500_PASS=L167';
else put 'ERROR: LIB500_FAIL=L167 actual=' actual;
run;
