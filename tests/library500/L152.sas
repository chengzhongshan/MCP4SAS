/* L152: median boundary 1; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(21,1,3);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L152';
else put 'ERROR: LIB500_FAIL=L152 actual=' actual;
run;
