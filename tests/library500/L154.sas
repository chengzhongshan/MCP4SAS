/* L154: median boundary 3; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(23,3,5);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L154';
else put 'ERROR: LIB500_FAIL=L154 actual=' actual;
run;
