/* L170: range boundary 9; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,9,11,-10);
if not missing(actual) and abs(actual-(21)) <= 1e-11*max(1,abs(21)) then put 'LIB500_PASS=L170';
else put 'ERROR: LIB500_FAIL=L170 actual=' actual;
run;
