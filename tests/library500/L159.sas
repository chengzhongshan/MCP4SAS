/* L159: median boundary 8; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(28,8,10);
if not missing(actual) and abs(actual-(10)) <= 1e-11*max(1,abs(10)) then put 'LIB500_PASS=L159';
else put 'ERROR: LIB500_FAIL=L159 actual=' actual;
run;
