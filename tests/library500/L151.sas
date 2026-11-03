/* L151: median boundary 0; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(20,0,2);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L151';
else put 'ERROR: LIB500_FAIL=L151 actual=' actual;
run;
