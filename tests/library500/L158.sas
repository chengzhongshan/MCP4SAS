/* L158: median boundary 7; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(27,7,9);
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L158';
else put 'ERROR: LIB500_FAIL=L158 actual=' actual;
run;
