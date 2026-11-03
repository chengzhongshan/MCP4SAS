/* L164: range boundary 3; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,3,5,-4);
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L164';
else put 'ERROR: LIB500_FAIL=L164 actual=' actual;
run;
