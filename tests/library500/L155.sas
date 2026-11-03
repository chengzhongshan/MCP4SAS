/* L155: median boundary 4; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(24,4,6);
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L155';
else put 'ERROR: LIB500_FAIL=L155 actual=' actual;
run;
