/* L165: range boundary 4; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,4,6,-5);
if not missing(actual) and abs(actual-(11)) <= 1e-11*max(1,abs(11)) then put 'LIB500_PASS=L165';
else put 'ERROR: LIB500_FAIL=L165 actual=' actual;
run;
