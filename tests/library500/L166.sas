/* L166: range boundary 5; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,5,7,-6);
if not missing(actual) and abs(actual-(13)) <= 1e-11*max(1,abs(13)) then put 'LIB500_PASS=L166';
else put 'ERROR: LIB500_FAIL=L166 actual=' actual;
run;
