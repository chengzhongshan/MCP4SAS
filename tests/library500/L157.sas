/* L157: median boundary 6; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(26,6,8);
if not missing(actual) and abs(actual-(8)) <= 1e-11*max(1,abs(8)) then put 'LIB500_PASS=L157';
else put 'ERROR: LIB500_FAIL=L157 actual=' actual;
run;
