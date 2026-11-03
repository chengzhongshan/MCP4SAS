/* L153: median boundary 2; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(22,2,4);
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L153';
else put 'ERROR: LIB500_FAIL=L153 actual=' actual;
run;
