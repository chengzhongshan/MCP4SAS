/* L163: range boundary 2; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,2,4,-3);
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L163';
else put 'ERROR: LIB500_FAIL=L163 actual=' actual;
run;
